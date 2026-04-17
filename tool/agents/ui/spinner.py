# ui/spinner.py
from rich.console import Console
from rich.live import Live
from rich.markdown import Markdown

console = Console(highlight=False)


class AgentUI:
    def __init__(self):
        self.console = console

    def start_thinking(self, message: str = "Processing"):
        """Show a minimal spinner on a single line."""
        # Using a simple 'dots' spinner, keeping it compact
        return self.console.status(f"[cyan]{message}...", spinner="dots")

    def display_response(self, response: str):
        """Render response as clean Markdown."""
        self.console.print("\n[bold blue]❯ Agent:[/bold blue]")
        # Markdown helps format code blocks/tables from AI perfectly
        self.console.print(Markdown(response))
        self.console.print("")

    def notify_loading(self, target: str):
        """Minimal loading hint."""
        self.console.print(f"[dim]→ Reading {target}[/dim]")
