#!/usr/bin/env python3
# Brave URL launcher — GTK4 keyboard-first "address bar" (Gruber Darker / Ayu).
#
# KEYBOARD (primary):
#   • Tab / Shift+Tab   -> move focus between protocol, profile, search, Open, and list
#   • Type + Enter      -> open typed URL (scheme auto-added)
#   • ↑ / ↓             -> move through history
#   • Enter / Space     -> open the highlighted history URL
#   • Delete            -> remove the highlighted history URL
#   • Ctrl+C            -> copy the highlighted history URL
#   • Esc / Q           -> close the window
# Mouse (secondary): click a URL to open, or use the Delete / Copy buttons.
#
# Launch: bind = SUPER+U, exec, ~/.config/hypr/scripts/url_launcher_gui.py

import os
import re
import subprocess

gi = __import__("gi")
gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Gtk, Gdk, Adw

CACHE = os.path.expanduser("~/.cache/url_launcher")
HIST_FILE = os.path.join(CACHE, "history")
MAX_HISTORY = 25
BRAVE_DIR = os.path.expanduser("~/.config/BraveSoftware/Brave-Origin")

# ---------------- Waybar / Gruber Darker palette ----------------
CSS = """
window {
    background-color: #0d0d0d;
    color: #ffffff;
}
.app {
    background-color: #0d0d0d;
}
.hdr {
    color: #6CD5FF;
    font-weight: bold;
    font-size: 15px;
    letter-spacing: 1px;
}
.dd {
    background-color: #181818;
    border: 1px solid #363652;
    border-radius: 10px;
}
.dd label, .dd button:selected {
    color: #e8e8e8;
}
.dd-l {
    color: #6f7a8c;
    font-size: 10px;
    letter-spacing: 1px;
}
.panel {
    background-color: #181818;
    border: 1px solid #363652;
    border-radius: 12px;
    padding: 4px;
}
entry {
    background-color: #0f0f0f;
    color: #ffffff;
    border: 1px solid #363652;
    border-radius: 10px;
    padding: 9px 12px;
    font-size: 15px;
}
entry:focus {
    border-color: #6DCFFF;
    background-color: #14141c;
}
entry placeholder, entry > placeholder {
    color: #5f6b80;
}
button {
    background: transparent;
    color: #dde4ef;
    border-radius: 9px;
    padding: 7px 14px;
}
.accent {
    background: #E6B450;
    color: #0d0d0d;
    font-weight: bold;
    border: none;
}
.accent:hover { background: #f0c96a; }
.accent:focus, .url-btn:focus { outline-color: #6DCFFF; }
.history-hdr {
    color: #9db0c9;
    font-size: 10px;
    letter-spacing: 2px;
    font-weight: bold;
}
row {
    background: transparent;
    color: #ffffff;
    border-radius: 8px;
    margin: 1px 0;
}
row:hover { background: rgba(109, 207, 255, 0.08); }
row:selected, row:selected:hover {
    background: #2a3a4e;
    color: #ffffff;
}
.url-lbl {
    color: #eaf0f7;
}
.url-lbl:selected { color: #ffffff; }
list { background: transparent; }
scrolledwindow { background: transparent; }
.shortcut {
    color: #5f6c80;
    font-size: 11px;
}
.shortcut kbd {
    color: #A8F0D8;
    font-size: 11px;
    font-weight: bold;
}
"""


def load_css():
    provider = Gtk.CssProvider()
    provider.load_from_string(CSS)
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )


def detect_profiles():
    profiles = []
    try:
        for name in os.listdir(BRAVE_DIR):
            p = os.path.join(BRAVE_DIR, name)
            if os.path.isfile(os.path.join(p, "Preferences")):
                profiles.append(name)
    except FileNotFoundError:
        pass
    if not profiles:
        profiles = ["Default"]
    if "Default" in profiles:
        profiles.remove("Default")
        profiles.insert(0, "Default")
    return profiles


def add_scheme(u, protocol):
    if re.match(r"^[a-zA-Z][a-zA-Z0-9+.\-]*://", u):
        return u
    if protocol == "auto":
        if re.match(
            r"^(localhost|127\.|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|"
            r"^\d+\.\d+\.\d+\.\d+$)",
            u, re.I,
        ):
            return "http://" + u
        return "https://" + u
    return protocol + "://" + u


def load_history():
    try:
        with open(HIST_FILE) as f:
            return [ln.strip() for ln in f if ln.strip()]
    except FileNotFoundError:
        return []


def write_history(urls):
    os.makedirs(CACHE, exist_ok=True)
    with open(HIST_FILE, "w") as f:
        f.write("\n".join(urls) + ("\n" if urls else ""))


def save_history(url):
    urls = load_history()
    if url in urls:
        urls.remove(url)
    urls.insert(0, url)
    write_history(urls[:MAX_HISTORY])


def remove_history(url):
    urls = load_history()
    if url in urls:
        urls.remove(url)
    write_history(urls)


class UrlBar(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(16)
        self.set_margin_bottom(16)
        self.set_margin_start(16)
        self.set_margin_end(16)

        # ---------------- header ----------------
        hd = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        banner = Gtk.Label()
        banner.set_markup("<span size='18pt' weight='bold'>🦁 Brave URL</span>")
        banner.add_css_class("hdr")
        banner.set_halign(Gtk.Align.START)
        hd.append(banner)
        self.append(hd)

        # ---------------- protocol + profile (labeled chips) ----------------
        ddrow = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

        proto_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        pl = Gtk.Label(label="PROTOCOL")
        pl.add_css_class("dd-l")
        pl.set_halign(Gtk.Align.START)
        proto_box.append(pl)
        self.protocol_dd = Gtk.DropDown.new_from_strings(["auto", "https", "http"])
        self.protocol_dd.add_css_class("dd")
        proto_box.append(self.protocol_dd)
        ddrow.append(proto_box)

        prof_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        fl = Gtk.Label(label="PROFILE")
        fl.add_css_class("dd-l")
        fl.set_halign(Gtk.Align.START)
        prof_box.append(fl)
        self.profile_dd = Gtk.DropDown.new_from_strings(detect_profiles())
        self.profile_dd.add_css_class("dd")
        prof_box.append(self.profile_dd)
        ddrow.append(prof_box)

        self.append(ddrow)

        # ---------------- address bar ----------------
        bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)

        self.entry = Gtk.SearchEntry()
        self.entry.set_hexpand(True)
        self.entry.set_placeholder_text("https://youtube.com")
        self.entry.connect("activate", self.on_open)
        bar.append(self.entry)

        open_btn = Gtk.Button(label="Open")
        open_btn.add_css_class("accent")
        open_btn.connect("clicked", self.on_open)
        bar.append(open_btn)

        self.append(bar)

        # ---------------- history ----------------
        hh = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        hist_label = Gtk.Label(label="HISTORY")
        hist_label.add_css_class("history-hdr")
        hist_label.set_halign(Gtk.Align.START)
        hh.append(hist_label)
        self.append(hh)

        self.list = Gtk.ListBox()
        self.list.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.list.connect("row-activated", self.on_row_activated)
        # keyboard: Delete / Ctrl+C act only while the history list has focus
        list_ctrl = Gtk.EventControllerKey.new()
        list_ctrl.connect("key-pressed", self.on_list_key)
        self.list.add_controller(list_ctrl)
        sc = Gtk.ScrolledWindow()
        sc.set_vexpand(True)
        sc.set_child(self.list)
        self.append(sc)
        self.reload_list()

        # ---------------- shortcut footer ----------------
        help_s = Gtk.Label(label=(
            "⏎ Open URL · "
            "⌨ ↑↓ select · "
            "⏎/Space open · "
            "⌦ Delete remove · "
            "Ctrl+C copy · "
            "Esc close"
        ))
        help_s.add_css_class("shortcut")
        help_s.set_justify(Gtk.Justification.CENTER)
        self.append(help_s)

        # keyboard: Esc/Q closes anywhere; Delete/Ctrl+C are handled on the list
        ctrl = Gtk.EventControllerKey.new()
        ctrl.connect("key-pressed", self.on_close_key)
        self.add_controller(ctrl)

        self.entry.grab_focus()

    # -------- helpers --------
    def current_profile(self):
        p = self.profile_dd.get_selected()
        return "Default" if p < 0 else self.profile_dd.get_model().get_string(p)

    def current_protocol(self):
        p = self.protocol_dd.get_selected()
        return "auto" if p < 0 else self.protocol_dd.get_model().get_string(p)

    def open(self, url):
        url = url.strip()
        if not url:
            return
        final = add_scheme(url, self.current_protocol())
        subprocess.Popen(
            ["brave-origin", "--profile-directory=" + self.current_profile(), "--app=" + final],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        save_history(final)
        self.reload_list()
        self.entry.set_text("")

    def on_open(self, *_):
        self.open(self.entry.get_text())

    def selected_url(self):
        row = self.list.get_selected_row()
        return row.url if row is not None else None

    # -------- list / keyboard --------
    def on_row_activated(self, _list, row):
        if row.url:
            self.open(row.url)

    def on_close_key(self, ctrl, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape and not (state & Gdk.ModifierType.CONTROL_MASK):
            wn = self.get_root()
            if hasattr(wn, "close"):
                wn.close()
            return True
        # 'Q' closes only when we are NOT typing in the search box
        if keyval == Gdk.KEY_q and not (state & Gdk.ModifierType.CONTROL_MASK):
            try:
                focus = self.get_root().get_focus()
            except Exception:
                focus = None
            if focus is not self.entry:
                wn = self.get_root()
                if hasattr(wn, "close"):
                    wn.close()
                return True
        return False

    def on_list_key(self, ctrl, keyval, keycode, state):
        url = self.selected_url()
        if url is None:
            return False
        if keyval in (Gdk.KEY_c, Gdk.KEY_C) and (state & Gdk.ModifierType.CONTROL_MASK):
            Gdk.Display.get_default().get_clipboard().set_text(url)
            return True
        if keyval == Gdk.KEY_Delete and not (state & Gdk.ModifierType.CONTROL_MASK):
            remove_history(url)
            self.reload_list()
            return True
        return False

    # -------- ui --------
    def reload_list(self):
        while (ch := self.list.get_first_child()) is not None:
            self.list.remove(ch)
        for url in load_history():
            row = Gtk.ListBoxRow()
            row.url = url
            box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            box.set_margin_top(2)
            box.set_margin_bottom(2)
            box.set_margin_start(4)
            box.set_margin_end(4)

            lbl = Gtk.Label(label=url)
            lbl.set_xalign(0.0)
            lbl.add_css_class("url-lbl")
            lbl.set_hexpand(True)
            box.append(lbl)

            # mouse-only helpers (keyboard uses the keys above)
            cpy = Gtk.Button(label="Copy")
            cpy.connect("clicked", self.copy_btn, url)
            cpy.set_focusable(False)
            box.append(cpy)

            dl = Gtk.Button(label="🗑")
            dl.connect("clicked", self.delete_btn, url)
            dl.set_focusable(False)
            box.append(dl)

            row.set_child(box)
            self.list.append(row)
        self.entry.grab_focus()

    def copy_btn(self, _btn, url):
        Gdk.Display.get_default().get_clipboard().set_text(url)

    def delete_btn(self, _btn, url):
        remove_history(url)
        self.reload_list()


class App(Gtk.Application):
    def do_activate(self):
        wn = Gtk.ApplicationWindow(application=self)
        wn.set_title("Brave URL Launcher")
        wn.set_default_size(560, 640)
        wn.set_child(UrlBar())
        wn.present()


def run():
    Adw.init()
    load_css()
    app = App()
    app.run(None)


if __name__ == "__main__":
    run()