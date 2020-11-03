# Layout

[![Showcase](https://i.ibb.co/XLp8DhP/GTK-DEBUG.png)](https://github.com/grkek/layout)

**Notice:** This project is <ins>experimental</ins>.

**Keep in mind:** The rendered window on the right side is a native Gtk window, not a browser.

# Installation

```bash
git clone git@github.com:grkek/layout.git
cd layout
shards install
```

# Usage

See the example and determin how everything works from that, it is a 3 line code file which just executes the builder, other than that everything is in either LTML or JavaScript.

```
# The -D tag defines a compile time flag,
# the flag defined below is an IO flag,
# which enables the Input/Output capabilities for the
# Duktape JS engine.
crystal run example/application -Dio
```

Instead of using Glade 3.x.x we are going to use this.