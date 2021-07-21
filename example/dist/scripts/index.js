/**
 *
 *
 * Index.js - Contains the business logic for the main application component.
 *
 *
 */

const appConfiguration = {
  window: {
    width: 1200,
    height: 800,
    title: "Monkey Shoulder"
  }
};

const textMutation = {
  updateNumberOne: function (_element, text) {
    var label = getElementByComponentId("numberOneLabel");
    label.setText(text);

    print(text);
  },

  updateNumberTwo: function (_element, text) {
    var label = getElementByComponentId("numberTwoLabel");
    label.setText(text);

    print(text);
  },
};