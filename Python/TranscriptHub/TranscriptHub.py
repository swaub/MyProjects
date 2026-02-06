#!/usr/bin/env python3

import tkinter as tk
from tkinter import ttk, scrolledtext, messagebox, filedialog
import re
from urllib.parse import urlparse, parse_qs
import threading
import os
from datetime import datetime

try:
    from youtube_transcript_api import YouTubeTranscriptApi
    from youtube_transcript_api.formatters import TextFormatter
except ImportError:
    import subprocess
    import sys
    print("Installing required dependencies...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "youtube-transcript-api"])
    from youtube_transcript_api import YouTubeTranscriptApi
    from youtube_transcript_api.formatters import TextFormatter

try:
    import requests
except ImportError:
    import subprocess
    import sys
    print("Installing requests...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests


class YouTubeTranscriptDownloader:
    def __init__(self, root):
        self.root = root
        self.root.title("TranscriptHub")
        self.root.geometry("800x600")

        style = ttk.Style()
        style.theme_use('clam')

        main_frame = ttk.Frame(root, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(3, weight=1)

        title_label = ttk.Label(main_frame, text="TranscriptHub",
                                font=('Arial', 16, 'bold'))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))

        url_label = ttk.Label(main_frame, text="YouTube URL:")
        url_label.grid(row=1, column=0, sticky=tk.W, pady=(0, 5))

        self.url_entry = ttk.Entry(main_frame, width=60, font=('Arial', 10))
        self.url_entry.grid(row=2, column=0, sticky=(tk.W, tk.E), padx=(0, 10))
        self.url_entry.bind('<Return>', lambda e: self.download_transcript())

        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=2, column=1, columnspan=2, sticky=tk.W)

        self.download_btn = ttk.Button(button_frame, text="Get Transcript",
                                      command=self.download_transcript)
        self.download_btn.grid(row=0, column=0, padx=(0, 5))

        self.clear_btn = ttk.Button(button_frame, text="Clear",
                                   command=self.clear_all)
        self.clear_btn.grid(row=0, column=1)

        preview_label = ttk.Label(main_frame, text="Preview:", font=('Arial', 12, 'bold'))
        preview_label.grid(row=3, column=0, sticky=tk.W, pady=(20, 5))

        text_frame = ttk.Frame(main_frame)
        text_frame.grid(row=4, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        text_frame.columnconfigure(0, weight=1)
        text_frame.rowconfigure(0, weight=1)

        self.text_preview = scrolledtext.ScrolledText(text_frame, wrap=tk.WORD,
                                                      width=70, height=20,
                                                      font=('Consolas', 10))
        self.text_preview.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        save_frame = ttk.Frame(main_frame)
        save_frame.grid(row=5, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))

        self.format_var = tk.StringVar(value="txt")
        ttk.Label(save_frame, text="Save as:").grid(row=0, column=0, padx=(0, 10))
        ttk.Radiobutton(save_frame, text="Text (.txt)", variable=self.format_var,
                       value="txt").grid(row=0, column=1, padx=(0, 10))
        ttk.Radiobutton(save_frame, text="Markdown (.md)", variable=self.format_var,
                       value="md").grid(row=0, column=2, padx=(0, 20))

        self.save_btn = ttk.Button(save_frame, text="Save to File",
                                  command=self.save_transcript, state=tk.DISABLED)
        self.save_btn.grid(row=0, column=3)

        self.status_var = tk.StringVar(value="Ready. Paste a YouTube URL and click 'Get Transcript'")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var,
                              relief=tk.SUNKEN, anchor=tk.W)
        status_bar.grid(row=6, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))

        self.current_transcript = None
        self.video_title = None

    def extract_video_id(self, url):
        patterns = [
            r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?]+)',
            r'(?:youtube\.com\/v\/)([^&\n?]+)',
        ]

        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)

        parsed = urlparse(url)
        if parsed.hostname in ['www.youtube.com', 'youtube.com', 'm.youtube.com']:
            query = parse_qs(parsed.query)
            if 'v' in query:
                return query['v'][0]

        return None

    def get_video_title(self, video_id):
        try:
            response = requests.get(f'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json')
            if response.status_code == 200:
                return response.json().get('title', f'video_{video_id}')
        except:
            pass
        return f'video_{video_id}'

    def download_transcript(self):
        url = self.url_entry.get().strip()

        if not url:
            messagebox.showwarning("Warning", "Please enter a YouTube URL")
            return

        video_id = self.extract_video_id(url)

        if not video_id:
            messagebox.showerror("Error", "Invalid YouTube URL. Please enter a valid YouTube video URL.")
            return

        self.status_var.set("Downloading transcript...")
        self.download_btn.config(state=tk.DISABLED)
        self.root.update()

        def download_thread():
            try:
                transcript_data = None

                try:
                    # Direct fetch (default language)
                    transcript_data = YouTubeTranscriptApi.get_transcript(video_id)
                except Exception as e:
                    try:
                        # Try to list available transcripts and find an English one
                        transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)

                        try:
                            # Try fetching manually created English subtitles
                            transcript = transcript_list.find_manually_created_transcript(['en', 'en-US', 'en-GB'])
                            transcript_data = transcript.fetch()
                        except:
                            try:
                                # Fallback to auto-generated English
                                transcript = transcript_list.find_generated_transcript(['en', 'en-US', 'en-GB'])
                                transcript_data = transcript.fetch()
                            except:
                                # Fallback to any available transcript
                                for transcript in transcript_list:
                                    transcript_data = transcript.fetch()
                                    break
                    except Exception as e2:
                        print(f"Error listing transcripts: {e2}")

                if not transcript_data:
                    self.root.after(0, lambda: messagebox.showerror("Error",
                        "No transcript/captions available for this video.\n\n"
                        "This tool only works with videos that have captions/subtitles enabled."))
                    self.root.after(0, lambda: self.download_btn.config(state=tk.NORMAL))
                    self.root.after(0, lambda: self.status_var.set("Error: No transcript available"))
                    return

                self.video_title = self.get_video_title(video_id)

                if self.format_var.get() == "md":
                    formatted_text = self.format_as_markdown(transcript_data, self.video_title, url)
                else:
                    formatted_text = self.format_as_text(transcript_data, self.video_title, url)

                self.current_transcript = formatted_text

                self.root.after(0, self.update_ui_success)

            except Exception as e:
                error_msg = str(e)
                self.root.after(0, lambda: self.update_ui_error(error_msg))

        thread = threading.Thread(target=download_thread, daemon=True)
        thread.start()

    def format_as_text(self, transcript_data, title, url):
        lines = []
        lines.append(f"Title: {title}")
        lines.append(f"URL: {url}")
        lines.append(f"Downloaded: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("-" * 60)
        lines.append("")

        for entry in transcript_data:
            if isinstance(entry, dict):
                text = entry.get('text', '').strip()
            else:
                text = getattr(entry, 'text', '').strip()
            if text:
                lines.append(text)

        return '\n'.join(lines)

    def format_as_markdown(self, transcript_data, title, url):
        lines = []
        lines.append(f"# {title}")
        lines.append("")
        lines.append(f"**URL:** [{url}]({url})")
        lines.append(f"**Downloaded:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("")
        lines.append("---")
        lines.append("")
        lines.append("## Transcript")
        lines.append("")

        current_paragraph = []
        for entry in transcript_data:
            if isinstance(entry, dict):
                text = entry.get('text', '').strip()
            else:
                text = getattr(entry, 'text', '').strip()
            if text:
                if text[0].isupper() and current_paragraph and current_paragraph[-1][-1] in '.!?':
                    lines.append(' '.join(current_paragraph))
                    lines.append("")
                    current_paragraph = [text]
                else:
                    current_paragraph.append(text)

        if current_paragraph:
            lines.append(' '.join(current_paragraph))

        return '\n'.join(lines)

    def update_ui_success(self):
        self.text_preview.delete(1.0, tk.END)
        self.text_preview.insert(1.0, self.current_transcript)
        self.save_btn.config(state=tk.NORMAL)
        self.download_btn.config(state=tk.NORMAL)
        self.status_var.set("Transcript downloaded successfully!")

    def update_ui_error(self, error_msg):
        self.download_btn.config(state=tk.NORMAL)
        self.status_var.set("Error occurred")

        if "No transcript" in error_msg:
            messagebox.showerror("Error",
                "No transcript/captions available for this video.\n\n"
                "This tool only works with videos that have captions/subtitles enabled.")
        else:
            messagebox.showerror("Error", f"Failed to download transcript:\n{error_msg}")

    def save_transcript(self):
        if not self.current_transcript:
            messagebox.showwarning("Warning", "No transcript to save")
            return

        safe_title = re.sub(r'[<>:"/\\|?*]', '_', self.video_title)[:100]

        ext = ".md" if self.format_var.get() == "md" else ".txt"

        file_path = filedialog.asksaveasfilename(
            defaultextension=ext,
            initialfile=safe_title + ext,
            filetypes=[
                ("Markdown files", "*.md") if self.format_var.get() == "md"
                else ("Text files", "*.txt"),
                ("All files", "*.*")
            ]
        )

        if file_path:
            try:
                if self.format_var.get() == "md" and not self.current_transcript.startswith("#"):
                    url = self.url_entry.get().strip()
                    video_id = self.extract_video_id(url)

                    try:
                        transcript_data = None

                        try:
                            transcript_data = YouTubeTranscriptApi.get_transcript(video_id)
                        except:
                            try:
                                transcript_list = YouTubeTranscriptApi.list_transcripts(video_id)
                                for transcript in transcript_list:
                                    try:
                                        transcript_data = transcript.fetch()
                                        break
                                    except:
                                        continue
                            except:
                                pass

                        if transcript_data:
                            self.current_transcript = self.format_as_markdown(
                                transcript_data, self.video_title, url)
                    except:
                        pass

                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(self.current_transcript)

                self.status_var.set(f"Saved to: {file_path}")
                messagebox.showinfo("Success", f"Transcript saved successfully to:\n{file_path}")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save file:\n{str(e)}")

    def clear_all(self):
        self.url_entry.delete(0, tk.END)
        self.text_preview.delete(1.0, tk.END)
        self.current_transcript = None
        self.video_title = None
        self.save_btn.config(state=tk.DISABLED)
        self.status_var.set("Ready. Paste a YouTube URL and click 'Get Transcript'")


def main():
    root = tk.Tk()
    app = YouTubeTranscriptDownloader(root)

    root.update_idletasks()
    width = root.winfo_width()
    height = root.winfo_height()
    x = (root.winfo_screenwidth() // 2) - (width // 2)
    y = (root.winfo_screenheight() // 2) - (height // 2)
    root.geometry(f'{width}x{height}+{x}+{y}')

    root.mainloop()


if __name__ == "__main__":
    main()