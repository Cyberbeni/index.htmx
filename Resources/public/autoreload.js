// workaround iOS not reconnecting to SSE when returning from background
if (navigator.maxTouchPoints > 1) {
	window.addEventListener("visibilitychange", function () {
		if (document.visibilityState === "visible") {
			const main = document.body.getElementsByTagName('main').item(0)
			const sse = main['htmx-internal-data'].sseEventSource
			if (sse) {
				sse.close()
				sse.onerror()
			}
		}
	})
}
