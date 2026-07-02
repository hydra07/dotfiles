"""Shared helpers for the xlsx (de)serialization tools.

Used by xlsx2json_full / json2xlsx_full and xlsx2zip / zip2xlsx.
The leading underscore keeps release.py from exporting it as a launcher.
"""
import datetime
import json
import sys

from openpyxl.styles import Border, Side


def setup_utf8_stdout() -> None:
    """Force UTF-8 stdout — Windows consoles default to cp1252/cp932."""
    if sys.stdout.encoding != "utf-8":
        sys.stdout.reconfigure(encoding="utf-8")


class ExcelJSONEncoder(json.JSONEncoder):
    """Serialize datetime/date/time with a type tag so decode_val can rebuild them."""

    def default(self, obj):
        if isinstance(obj, (datetime.datetime, datetime.date)):
            return {"__type__": "datetime", "value": obj.isoformat()}
        if isinstance(obj, datetime.time):
            return {"__type__": "time", "value": obj.isoformat()}
        return super().default(obj)


def decode_val(val):
    """Inverse of ExcelJSONEncoder: rebuild datetime/time from the type tag."""
    if isinstance(val, dict):
        t = val.get("__type__")
        if t == "datetime":
            try:
                return datetime.datetime.fromisoformat(val["value"])
            except Exception:
                return val["value"]
        if t == "time":
            try:
                return datetime.time.fromisoformat(val["value"])
            except Exception:
                return val["value"]
    return val


def get_hex_color(color_obj):
    """Extract the ARGB/RGB hex string from an openpyxl Color, or None."""
    if not color_obj:
        return None
    if color_obj.type == "rgb":
        return color_obj.rgb
    return None


def thin_border() -> Border:
    """The light-gray thin border applied across rebuilt sheets."""
    side = Side(border_style="thin", color="D3D3D3")
    return Border(left=side, right=side, top=side, bottom=side)
