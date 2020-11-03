# Layout

[![Showcase](https://i.ibb.co/XLp8DhP/GTK-DEBUG.png)](https://github.com/grkek/layout)

**Notice:** This project is <ins>experimental</ins>.

**Keep in mind:** The rendered window on the left side is a native Gtk window, not a browser.

# Installation

```bash
git clone git@github.com:grkek/layout.git
cd layout
shards install
```

# Usage

See the example and determin how everything works from that, it is a 3 line code file which just executes the builder, other than that everything is in either LTML or JavaScript.

```
# The GTK_DEBUG environment constant spawns a sepparate window
# with which you can debug UI elements.
GTK_DEBUG=interactive crystal run example/application.cr
```

When you compile the application click the `Dark mode` button to feel how smooth and comfortable the transition is.

Instead of using Glade 3.x.x we are going to use this.