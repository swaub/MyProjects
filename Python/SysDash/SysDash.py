import time
import psutil
from rich.console import Console
from rich.layout import Layout
from rich.panel import Panel
from rich.table import Table
from rich.live import Live
from rich.text import Text
from rich import box
import os

console = Console()

def get_cpu_panel():
    cpu_percent = psutil.cpu_percent(interval=None, percpu=True)
    avg_cpu = sum(cpu_percent) / len(cpu_percent)
    
    table = Table(box=None, expand=True, show_header=False)
    table.add_column("Core", style="cyan")
    table.add_column("Usage", style="green")
    
    for i, p in enumerate(cpu_percent):
        color = "green" if p < 60 else "yellow" if p < 85 else "red"
        bar_len = int(p / 5)
        bar = f"[{color}]{'|' * bar_len}[/{color}]"
        table.add_row(f"Core {i}", f"{p:>4.1f}% {bar}")
        
    return Panel(
        table, 
        title=f"CPU Usage ({avg_cpu:.1f}%)", 
        border_style="blue"
    )

def get_mem_panel():
    mem = psutil.virtual_memory()
    swap = psutil.swap_memory()
    
    table = Table(box=None, expand=True)
    table.add_column("Type", style="cyan")
    table.add_column("Used", style="yellow")
    table.add_column("Total", style="white")
    table.add_column("%", style="magenta")
    
    table.add_row(
        "RAM", 
        f"{mem.used / (1024**3):.1f} GB", 
        f"{mem.total / (1024**3):.1f} GB", 
        f"{mem.percent}%"
    )
    table.add_row(
        "Swap", 
        f"{swap.used / (1024**3):.1f} GB", 
        f"{swap.total / (1024**3):.1f} GB", 
        f"{swap.percent}%"
    )

    return Panel(table, title="Memory", border_style="green")

def get_disk_panel():
    table = Table(box=None, expand=True)
    table.add_column("Device", style="cyan")
    table.add_column("Mount", style="white")
    table.add_column("Usage", style="magenta")
    
    for part in psutil.disk_partitions():
        try:
            usage = psutil.disk_usage(part.mountpoint)
            table.add_row(
                part.device, 
                part.mountpoint, 
                f"{usage.percent}%"
            )
        except PermissionError:
            continue

    return Panel(table, title="Disk Usage", border_style="yellow")

def generate_layout():
    layout = Layout()
    layout.split_column(
        Layout(name="top", ratio=1),
        Layout(name="bottom", ratio=1)
    )
    layout["top"].split_row(
        Layout(name="cpu"),
        Layout(name="mem")
    )
    layout["bottom"].update(get_disk_panel())
    return layout

def main():
    layout = generate_layout()
    
    console.print("[bold cyan]SysDash[/bold cyan] - Press Ctrl+C to exit")
    
    with Live(layout, refresh_per_second=1, screen=True) as live:
        try:
            while True:
                layout["top"]["cpu"].update(get_cpu_panel())
                layout["top"]["mem"].update(get_mem_panel())
                layout["bottom"].update(get_disk_panel())
                time.sleep(1)
        except KeyboardInterrupt:
            pass

if __name__ == "__main__":
    main()
