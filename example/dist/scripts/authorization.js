function onComponentDidUpdate(_state, classId, eventType) {
  const usernameField = getElementByClassId(classId);

  switch (eventType) {
    case "KEY_PRESS":
      var content = usernameField.getText();
      if (content.length > 6) {
        usernameField.setForegroundColor(200, 0, 0, 100);
      } else {
        usernameField.setForegroundColor(0, 0, 0, 100);
      }
  }
}