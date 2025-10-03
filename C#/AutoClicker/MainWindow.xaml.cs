using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Input;
using System.Windows.Threading;

namespace AutoClicker
{
    public partial class MainWindow : Window
    {
        [DllImport("user32.dll")]
        private static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);

        [DllImport("user32.dll")]
        private static extern bool SetCursorPos(int X, int Y);

        [DllImport("user32.dll")]
        private static extern bool GetCursorPos(out POINT lpPoint);

        [StructLayout(LayoutKind.Sequential)]
        public struct POINT
        {
            public int X;
            public int Y;
        }

        private const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
        private const uint MOUSEEVENTF_LEFTUP = 0x0004;
        private const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
        private const uint MOUSEEVENTF_RIGHTUP = 0x0010;
        private const uint MOUSEEVENTF_MIDDLEDOWN = 0x0020;
        private const uint MOUSEEVENTF_MIDDLEUP = 0x0040;

        private DispatcherTimer? _clickTimer;
        private DispatcherTimer? _statsTimer;
        private bool _isRunning = false;
        private int _totalClicks = 0;
        private int _currentRunClicks = 0;
        private Stopwatch _stopwatch = new Stopwatch();
        private uint _currentHotkeyVK = 0x75;
        private IntPtr _windowHandle;

        public MainWindow()
        {
            InitializeComponent();
            InitializeTimers();
            UpdateUIWithHotkey();
        }

        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);
            _windowHandle = new System.Windows.Interop.WindowInteropHelper(this).Handle;
            RegisterCurrentHotKey();
        }

        private void InitializeTimers()
        {
            _statsTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(100)
            };
            _statsTimer.Tick += StatsTimer_Tick;
        }

        private void RegisterCurrentHotKey()
        {
            var source = System.Windows.Interop.HwndSource.FromHwnd(_windowHandle);
            source?.AddHook(HwndHook);

            if (_currentHotkeyVK != 0)
            {
                RegisterHotKey(_windowHandle, 1, 0, _currentHotkeyVK);
            }
        }

        private void UnregisterCurrentHotKey()
        {
            if (_windowHandle != IntPtr.Zero && _currentHotkeyVK != 0)
            {
                UnregisterHotKey(_windowHandle, 1);
            }
        }

        private void HotkeyTextBox_PreviewKeyDown(object sender, KeyEventArgs e)
        {
            e.Handled = true;

            Key key = e.Key == Key.System ? e.SystemKey : e.Key;

            if (key == Key.LeftCtrl || key == Key.RightCtrl ||
                key == Key.LeftAlt || key == Key.RightAlt ||
                key == Key.LeftShift || key == Key.RightShift ||
                key == Key.LWin || key == Key.RWin)
            {
                return;
            }

            uint vk = (uint)KeyInterop.VirtualKeyFromKey(key);

            SetNewHotkey(key, vk);
        }

        private void SetNewHotkey(Key key, uint virtualKey)
        {
            UnregisterCurrentHotKey();

            _currentHotkeyVK = virtualKey;
            HotkeyTextBox.Text = key.ToString();

            if (_windowHandle != IntPtr.Zero)
            {
                RegisterHotKey(_windowHandle, 1, 0, _currentHotkeyVK);
            }

            UpdateUIWithHotkey();

            MessageBox.Show($"Hotkey changed to: {key}", "Hotkey Updated",
                MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void ClearHotkey_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show(
                "Are you sure you want to clear the hotkey?\n\n" +
                "You will need to use the Start button to begin clicking.",
                "Clear Hotkey",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                UnregisterCurrentHotKey();
                _currentHotkeyVK = 0;
                HotkeyTextBox.Text = "(None)";
                UpdateUIWithHotkey();
            }
        }

        private void UpdateUIWithHotkey()
        {
            string hotkeyName = HotkeyTextBox.Text;

            if (hotkeyName == "(None)" || string.IsNullOrEmpty(hotkeyName))
            {
                StartStopButton.Content = "▶️ Start";
                HotkeyHintTextBlock.Text = "No hotkey set - use Start button only";
            }
            else
            {
                StartStopButton.Content = $"▶️ Start ({hotkeyName})";
                HotkeyHintTextBlock.Text = $"Press {hotkeyName} to start/stop clicking";
            }
        }

        [DllImport("user32.dll")]
        private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

        [DllImport("user32.dll")]
        private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

        private IntPtr HwndHook(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
        {
            const int WM_HOTKEY = 0x0312;
            if (msg == WM_HOTKEY && wParam.ToInt32() == 1)
            {
                ToggleClicking();
                handled = true;
            }
            return IntPtr.Zero;
        }

        private void StartStop_Click(object sender, RoutedEventArgs e)
        {
            ToggleClicking();
        }

        private void ToggleClicking()
        {
            if (_isRunning)
            {
                StopClicking();
            }
            else
            {
                StartClicking();
            }
        }

        private void StartClicking()
        {
            if (!ValidateInputs())
                return;

            _isRunning = true;
            _currentRunClicks = 0;
            _stopwatch.Restart();

            string hotkeyName = HotkeyTextBox.Text;
            if (hotkeyName == "(None)" || string.IsNullOrEmpty(hotkeyName))
            {
                StartStopButton.Content = "⏸️ Stop";
            }
            else
            {
                StartStopButton.Content = $"⏸️ Stop ({hotkeyName})";
            }
            StartStopButton.Background = System.Windows.Media.Brushes.Red;
            StatusTextBlock.Text = "Running";
            StatusTextBlock.Foreground = System.Windows.Media.Brushes.Green;

            SetControlsEnabled(false);

            int interval = int.Parse(IntervalTextBox.Text);

            _clickTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(interval)
            };
            _clickTimer.Tick += ClickTimer_Tick;
            _clickTimer.Start();

            _statsTimer?.Start();
        }

        private void StopClicking()
        {
            _isRunning = false;
            _stopwatch.Stop();

            _clickTimer?.Stop();
            _statsTimer?.Stop();

            UpdateUIWithHotkey();
            StartStopButton.Background = new System.Windows.Media.SolidColorBrush(
                System.Windows.Media.Color.FromRgb(76, 175, 80));
            StatusTextBlock.Text = "Stopped";
            StatusTextBlock.Foreground = System.Windows.Media.Brushes.Gray;

            SetControlsEnabled(true);
        }

        private void ClickTimer_Tick(object? sender, EventArgs e)
        {
            PerformClick();

            if (RepeatCountRadio.IsChecked == true)
            {
                int maxClicks = int.Parse(ClickCountTextBox.Text);
                if (_currentRunClicks >= maxClicks)
                {
                    StopClicking();
                }
            }
        }

        private void StatsTimer_Tick(object? sender, EventArgs e)
        {
            TimeSpan elapsed = _stopwatch.Elapsed;
            TimeElapsedTextBlock.Text = $"{elapsed:hh\\:mm\\:ss}";

            CurrentRunClicksTextBlock.Text = _currentRunClicks.ToString();
            TotalClicksTextBlock.Text = _totalClicks.ToString();
        }

        private void PerformClick()
        {
            try
            {
                GetCursorPos(out POINT currentPos);

                if (FixedPositionRadio.IsChecked == true)
                {
                    int x = int.Parse(FixedXTextBox.Text);
                    int y = int.Parse(FixedYTextBox.Text);
                    SetCursorPos(x, y);
                }

                uint downFlag, upFlag;
                switch (ClickTypeComboBox.SelectedIndex)
                {
                    case 0:
                        downFlag = MOUSEEVENTF_LEFTDOWN;
                        upFlag = MOUSEEVENTF_LEFTUP;
                        break;
                    case 1:
                        downFlag = MOUSEEVENTF_RIGHTDOWN;
                        upFlag = MOUSEEVENTF_RIGHTUP;
                        break;
                    case 2:
                        downFlag = MOUSEEVENTF_MIDDLEDOWN;
                        upFlag = MOUSEEVENTF_MIDDLEUP;
                        break;
                    default:
                        downFlag = MOUSEEVENTF_LEFTDOWN;
                        upFlag = MOUSEEVENTF_LEFTUP;
                        break;
                }

                int clickCount = ClickModeComboBox.SelectedIndex == 1 ? 2 : 1;

                for (int i = 0; i < clickCount; i++)
                {
                    mouse_event(downFlag, 0, 0, 0, 0);
                    mouse_event(upFlag, 0, 0, 0, 0);

                    if (i < clickCount - 1)
                    {
                        System.Threading.Thread.Sleep(50);
                    }
                }

                if (FixedPositionRadio.IsChecked == true && CurrentPositionRadio.IsChecked == false)
                {
                }

                _currentRunClicks++;
                _totalClicks++;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error performing click: {ex.Message}", "Error",
                    MessageBoxButton.OK, MessageBoxImage.Error);
                StopClicking();
            }
        }

        private void GetCurrentPosition_Click(object sender, RoutedEventArgs e)
        {
            GetCursorPos(out POINT pos);
            FixedXTextBox.Text = pos.X.ToString();
            FixedYTextBox.Text = pos.Y.ToString();
        }

        private void ResetStats_Click(object sender, RoutedEventArgs e)
        {
            var result = MessageBox.Show("Are you sure you want to reset all statistics?",
                "Reset Statistics", MessageBoxButton.YesNo, MessageBoxImage.Question);

            if (result == MessageBoxResult.Yes)
            {
                _totalClicks = 0;
                _currentRunClicks = 0;
                TotalClicksTextBlock.Text = "0";
                CurrentRunClicksTextBlock.Text = "0";
                TimeElapsedTextBlock.Text = "00:00:00";
            }
        }

        private bool ValidateInputs()
        {
            if (!int.TryParse(IntervalTextBox.Text, out int interval) || interval < 1)
            {
                MessageBox.Show("Please enter a valid interval (minimum 1ms)", "Invalid Input",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            if (interval < 10)
            {
                var result = MessageBox.Show(
                    "Very fast clicking intervals may cause system instability or be detected as suspicious activity.\n\n" +
                    "Continue anyway?",
                    "Warning", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.No)
                    return false;
            }

            if (FixedPositionRadio.IsChecked == true)
            {
                if (!int.TryParse(FixedXTextBox.Text, out int x) || !int.TryParse(FixedYTextBox.Text, out int y))
                {
                    MessageBox.Show("Please enter valid X and Y coordinates", "Invalid Input",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return false;
                }
            }

            if (RepeatCountRadio.IsChecked == true)
            {
                if (!int.TryParse(ClickCountTextBox.Text, out int count) || count < 1)
                {
                    MessageBox.Show("Please enter a valid click count (minimum 1)", "Invalid Input",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return false;
                }
            }

            return true;
        }

        private void SetControlsEnabled(bool enabled)
        {
            IntervalTextBox.IsEnabled = enabled;
            ClickTypeComboBox.IsEnabled = enabled;
            ClickModeComboBox.IsEnabled = enabled;
            CurrentPositionRadio.IsEnabled = enabled;
            FixedPositionRadio.IsEnabled = enabled;
            FixedXTextBox.IsEnabled = enabled && FixedPositionRadio.IsChecked == true;
            FixedYTextBox.IsEnabled = enabled && FixedPositionRadio.IsChecked == true;
            RepeatForeverRadio.IsEnabled = enabled;
            RepeatCountRadio.IsEnabled = enabled;
            ClickCountTextBox.IsEnabled = enabled && RepeatCountRadio.IsChecked == true;
            HotkeyTextBox.IsEnabled = enabled;
        }

        protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
        {
            UnregisterCurrentHotKey();

            if (_isRunning)
            {
                StopClicking();
            }

            base.OnClosing(e);
        }
    }
}
