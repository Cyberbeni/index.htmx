// workaround iOS not reconnecting to SSE when returning from background
if (navigator.maxTouchPoints > 1) {
	window.addEventListener("visibilitychange", function () {
		if (document.visibilityState === "visible") {
			const main = document.body.getElementsByTagName('main').item(0)
			main['htmx-internal-data'].sseEventSource.close()
			main['htmx-internal-data'].sseEventSource.onerror()
		}
	})
}
