# Zoom

## Summary

Zoom Workplace is a video conferencing and collaboration platform supporting meetings, webinars, chat, and screen sharing.

## Links

- [zoom.us](https://zoom.us)
- [Linux install docs (Fedora quick-docs)](https://docs.fedoraproject.org/en-US/quick-docs/zoom/)
- [Zoom Linux download center](https://zoom.us/download?os=linux)
- [Zoom support](https://support.zoom.com)

## Operation

### Install (Fedora — RPM)

Download the latest x86_64 RPM directly from Zoom and install it with `dnf`:

```bash
cd /tmp
curl -fL "https://zoom.us/client/latest/zoom_x86_64.rpm" -o zoom_x86_64.rpm
sudo dnf install ./zoom_x86_64.rpm
```

Zoom does not register a DNF repository, so updates must be applied by re-running the commands above with the latest RPM.

### Upgrade

Re-download and reinstall the RPM — `dnf` will detect the newer version and upgrade in place:

```bash
cd /tmp
curl -fL "https://zoom.us/client/latest/zoom_x86_64.rpm" -o zoom_x86_64.rpm
sudo dnf install ./zoom_x86_64.rpm
```

### Uninstall

```bash
sudo dnf remove zoom
```

### Launch

Launch from the KDE application menu or:

```bash
zoom
```

### Config location

```
~/.zoom/
~/.config/zoomus.conf
```

## Troubleshooting

<!-- Record issues and resolutions here as they occur -->
