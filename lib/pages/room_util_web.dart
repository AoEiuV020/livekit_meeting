import 'dart:html';

roomCloseApp() {
  // web可能无法关闭当前页，会留下一个空白页，
  // Scripts may close only the windows that were opened by them.
  window.close();
}
