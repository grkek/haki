let button = std.element.button.create(std.element.getElementById("mainBox"));
button.setLabel("Hello, World!");

std.element.button.create(std.element.getElementById("mainBox")).setLabel("1");
std.element.button.create(std.element.getElementById("mainBox")).setLabel("2");
std.element.button.create(std.element.getElementById("mainBox")).setLabel("3");
std.element.button.create(std.element.getElementById("mainBox")).setLabel("4");
std.element.button.create(std.element.getElementById("mainBox")).setLabel("5");

let label = std.element.label.create(std.element.getElementById("mainBox"));
label.setLabel("Bye, World!");

button.properties.onPress = function() {
  button.setLabel(std.minuscule.uuid());
  label.setLabel(std.minuscule.uuid());

  console.log(mainBox.state.children)

  mainBox.state.children.forEach(child => {
    console.log("...Logging a child...")
    console.log(globalThis[child].state.name)
  });
};

button.properties.onKeyPress = function(key) {
  // If enter is pressed
  if(key === 65293){
    button.setLabel(std.minuscule.uuid());
    label.setLabel(std.minuscule.uuid());
  }
}