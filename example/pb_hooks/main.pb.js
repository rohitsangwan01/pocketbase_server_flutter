routerAdd("GET", "/hello/{name}", (e) => {
  let name = e.request.pathValue("name");
  // Send callback to native code
  let result = nativeEvent("GetRequest", "FromJS");
  return e.json(200, { message: "Hello " + name + " Result: " + result });
});

onRecordAfterUpdateSuccess((e) => {
  console.log("user updated...", e.record.get("email"));
  e.next();
}, "users");
