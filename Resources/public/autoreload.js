// workaround iOS not reconnecting to SSE when returning from background
if (navigator.maxTouchPoints > 1) {
	window.addEventListener("visibilitychange", function () {
		if (document.visibilityState === "visible") {
			location.reload()
		}
	})
}
