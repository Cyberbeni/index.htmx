import Logging

let Log = {
	var logger = Logger(label: "_")
	#if DEBUG
		logger.logLevel = .debug
	#endif
	return logger
}()
