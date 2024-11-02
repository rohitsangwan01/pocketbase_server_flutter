package main

/*
typedef void (*FlutterBridge)(const char *command, const char *data);
extern FlutterBridge flutterBridge;
extern void callFlutterBridgeHelper(const char* command, const char* data);
*/
import "C"
import (
	"fmt"
	"net/http"
	"os"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

var app *pocketbase.PocketBase

//export registerBridgeCallback
func registerBridgeCallback(callback C.FlutterBridge) {
	C.flutterBridge = callback
}

//export startPocketbase
func startPocketbase(path *C.char, port *C.char, hostname *C.char, getApiLogs bool) {
	goHostname := C.GoString(hostname)
	goPort := C.GoString(port)
	goPath := C.GoString(path)

	os.Args = append(os.Args, "serve", "--http", goHostname+":"+goPort)
	appConfig := pocketbase.Config{
		DefaultDataDir: goPath,
	}

	if app != nil {
		sendCommand("log", "Pocketbase is already running")
		stopPocketbase()
	}

	app = pocketbase.NewWithConfig(appConfig)
	setupPocketbaseCallbacks(app, true)

	serverUrl := "http://" + goHostname + ":" + goPort
	sendCommand("onServerStarting", fmt.Sprintln("Server starting at:", serverUrl+"\n",
		"➜ REST API: ", serverUrl+"/api/\n",
		"➜ Admin UI: ", serverUrl+"/_/"))

	if err := app.Start(); err != nil {
		sendCommand("error", fmt.Sprintln("Error: ", "Failed to start pocketbase server: ", err))
		app = nil
	}
}

//export stopPocketbase
func stopPocketbase() {
	sendCommand("log", "Stopping pocketbase...")
	if app == nil {
		sendCommand("log", "Pocketbase is not running")
		return
	}
	app.OnTerminate().Trigger(&core.TerminateEvent{App: app})
	app = nil
	sendCommand("log", "Pocketbase stopped")
}

//export isRunning
func isRunning() bool {
	return app != nil
}

//export getVersion
func getVersion() *C.char {
	return C.CString(pocketbase.Version)
}

func sendCommand(command string, data string) {
	cCommand := C.CString(command)
	cData := C.CString(data)
	C.callFlutterBridgeHelper(cCommand, cData)
}

// Hooks :https://pocketbase.io/docs/event-hooks/
func setupPocketbaseCallbacks(app *pocketbase.PocketBase, getApiLogs bool) {
	// Setup callbacks
	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		sendCommand("OnBeforeServe", "")
		if getApiLogs {
			e.Router.Use(ApiLogsMiddleWare(app))
		}
		// setup a native Get request handler
		e.Router.AddRoute(echo.Route{
			Method: http.MethodGet,
			Path:   "/api/nativeGet",
			Handler: func(context echo.Context) error {
				sendCommand("nativeGetRequest", context.QueryParams().Encode())
				return context.JSON(http.StatusOK, map[string]string{
					"success": "true",
				})
			},
		})
		// setup a native Post request handler
		e.Router.AddRoute(echo.Route{
			Method: http.MethodGet,
			Path:   "/api/nativePost",
			Handler: func(context echo.Context) error {
				form, error := context.FormValues()
				if error != nil {
					return context.JSON(http.StatusBadRequest, map[string]string{
						"error": error.Error(),
					})
				}
				sendCommand("nativePostRequest", form.Encode())
				return context.JSON(http.StatusOK, map[string]string{
					"success": "true",
				})
			},
		})
		return nil
	})
	app.OnBeforeBootstrap().Add(func(e *core.BootstrapEvent) error {
		sendCommand("OnBeforeBootstrap", "")
		return nil
	})
	app.OnAfterBootstrap().Add(func(e *core.BootstrapEvent) error {
		sendCommand("OnAfterBootstrap", "")
		return nil
	})
	app.OnTerminate().Add(func(e *core.TerminateEvent) error {
		app = nil
		sendCommand("OnTerminate", "")
		return nil
	})
}

func ApiLogsMiddleWare(app core.App) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			request := c.Request()
			fullPath := request.URL.Host + request.URL.Path + "?" + request.URL.RawQuery
			sendCommand("apiLogs", fullPath)
			return next(c)
		}
	}
}

//export enforce_binding
func enforce_binding() {}

func main() {}
