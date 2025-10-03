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
        // Win32 API imports for mouse control
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

        // Mouse event flags
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
        private uint _currentHotkeyVK = 0x75; // Default F6
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
            // Stats update timer (every 100ms)
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

            // Register the current hotkey
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

            // Get the key pressed
            Key key = e.Key == Key.System ? e.SystemKey : e.Key;

            // Ignore modifier keys alone
            if (key == Key.LeftCtrl || key == Key.RightCtrl ||
                key == Key.LeftAlt || key == Key.RightAlt ||
                key == Key.LeftShift || key == Key.RightShift ||
                key == Key.LWin || key == Key.RWin)
            {
                return;
            }

            // Convert WPF Key to Virtual Key Code
            uint vk = (uint)KeyInterop.VirtualKeyFromKey(key);

            // Update the hotkey
            SetNewHotkey(key, vk);
        }

        private void SetNewHotkey(Key key, uint virtualKey)
        {
            // Unregister old hotkey
            UnregisterCurrentHotKey();

            // Set new hotkey
            _currentHotkeyVK = virtualKey;
            HotkeyTextBox.Text = key.ToString();

            // Register new hotkey
            if (_windowHandle != IntPtr.Zero)
            {
                RegisterHotKey(_windowHandle, 1, 0, _currentHotkeyVK);
            }

            // Update UI
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
            // Validate inputs
            if (!ValidateInputs())
                return;

            _isRunning = true;
            _currentRunClicks = 0;
            _stopwatch.Restart();

            // Update UI
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

            // Disable configuration controls
            SetControlsEnabled(false);

            // Get interval
            int interval = int.Parse(IntervalTextBox.Text);

            // Start click timer
            _clickTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(interval)
            };
            _clickTimer.Tick += ClickTimer_Tick;
            _clickTimer.Start();

            // Start stats timer
            _statsTimer?.Start();
        }

        private void StopClicking()
        {
            _isRunning = false;
            _stopwatch.Stop();

            // Stop timers
            _clickTimer?.Stop();
            _statsTimer?.Stop();

            // Update UI
            UpdateUIWithHotkey();
            StartStopButton.Background = new System.Windows.Media.SolidColorBrush(
                System.Windows.Media.Color.FromRgb(76, 175, 80));
            StatusTextBlock.Text = "Stopped";
            StatusTextBlock.Foreground = System.Windows.Media.Brushes.Gray;

            // Enable configuration controls
            SetControlsEnabled(true);
        }

        private void ClickTimer_Tick(object? sender, EventArgs e)
        {
            PerformClick();

            // Check if we need to stop (limited clicks mode)
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
            // Update elapsed time
            TimeSpan elapsed = _stopwatch.Elapsed;
            TimeElapsedTextBlock.Text = $"{elapsed:hh\\:mm\\:ss}";

            // Update click counts
            CurrentRunClicksTextBlock.Text = _currentRunClicks.ToString();
            TotalClicksTextBlock.Text = _totalClicks.ToString();
        }

        private void PerformClick()
        {
            try
            {
                // Save current position
                GetCursorPos(out POINT currentPos);

                // Move to target position if fixed position mode
                if (FixedPositionRadio.IsChecked == true)
                {
                    int x = int.Parse(FixedXTextBox.Text);
                    int y = int.Parse(FixedYTextBox.Text);
                    SetCursorPos(x, y);
                }

                // Determine click type
                uint downFlag, upFlag;
                switch (ClickTypeComboBox.SelectedIndex)
                {
                    case 0: // Left Click
                        downFlag = MOUSEEVENTF_LEFTDOWN;
                        upFlag = MOUSEEVENTF_LEFTUP;
                        break;
                    case 1: // Right Click
                        downFlag = MOUSEEVENTF_RIGHTDOWN;
                        upFlag = MOUSEEVENTF_RIGHTUP;
                        break;
                    case 2: // Middle Click
                        downFlag = MOUSEEVENTF_MIDDLEDOWN;
                        upFlag = MOUSEEVENTF_MIDDLEUP;
                        break;
                    default:
                        downFlag = MOUSEEVENTF_LEFTDOWN;
                        upFlag = MOUSEEVENTF_LEFTUP;
                        break;
                }

                // Perform click(s)
                int clickCount = ClickModeComboBox.SelectedIndex == 1 ? 2 : 1; // Double or Single

                for (int i = 0; i < clickCount; i++)
                {
                    mouse_event(downFlag, 0, 0, 0, 0);
                    mouse_event(upFlag, 0, 0, 0, 0);

                    if (i < clickCount - 1)
                    {
                        // Small delay between clicks in double-click mode
                        System.Threading.Thread.Sleep(50);
                    }
                }

                // Restore cursor position if using fixed position
                if (FixedPositionRadio.IsChecked == true && CurrentPositionRadio.IsChecked == false)
                {
                    // Position was already set, no need to restore
                }

                // Update statistics
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
            // Validate interval
            if (!int.TryParse(IntervalTextBox.Text, out int interval) || interval < 1)
            {
                MessageBox.Show("Please enter a valid interval (minimum 1ms)", "Invalid Input",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return false;
            }

            // Warn if interval is too fast
            if (interval < 10)
            {
                var result = MessageBox.Show(
                    "Very fast clicking intervals may cause system instability or be detected as suspicious activity.\n\n" +
                    "Continue anyway?",
                    "Warning", MessageBoxButton.YesNo, MessageBoxImage.Warning);

                if (result == MessageBoxResult.No)
                    return false;
            }

            // Validate fixed position if selected
            if (FixedPositionRadio.IsChecked == true)
            {
                if (!int.TryParse(FixedXTextBox.Text, out int x) || !int.TryParse(FixedYTextBox.Text, out int y))
                {
                    MessageBox.Show("Please enter valid X and Y coordinates", "Invalid Input",
                        MessageBoxButton.OK, MessageBoxImage.Warning);
                    return false;
                }
            }

            // Validate click count if selected
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
            // Unregister hotkey
            UnregisterCurrentHotKey();

            // Stop clicking if running
            if (_isRunning)
            {
                StopClicking();
            }

            base.OnClosing(e);
        }
    }
}
