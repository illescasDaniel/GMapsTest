/*
The MIT License (MIT)

Copyright (c) 2019 Daniel Illescas Romero
https://github.com/illescasDaniel/BetterLogger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

public class BetterLogger {

	public static let `default` = BetterLogger(name: "Default")

	public let name: String
	public var handlers: [LoggerHandler]
	public var listeners: [BetterLogger.Severity: () -> Void]
	
	init(
		name: String,
		handlers: [LoggerHandler] = [ConsoleLoggerHandler(formatter: DefaultLoggerOutputFormatter())],
		listeners: [BetterLogger.Severity: () -> Void] = [:]
	) {
		self.name = name
		self.handlers = handlers
		self.listeners = listeners
	}

	public func verbose(
		_ messageOrValue: Any,
		context: [String: Any] = [:],

		_file: String = #file, _function: String = #function, _line: Int = #line, _column: Int = #column
	) {
		self.listeners[.verbose]?()
		for handler in self.handlers {
			handler.log(.init(
				loggerName: self.name,
				value: messageOrValue, severity: .verbose, context: context,
				metadata: .init(file: _file, function: _function, line: _line, column: _column)	
			))
		}
	}
	
	public func info(
		_ messageOrValue: Any,
		context: [String: Any] = [:],

		_file: String = #file, _function: String = #function, _line: Int = #line, _column: Int = #column
	) {
		self.listeners[.info]?()
		for handler in self.handlers {
			handler.log(.init(
				loggerName: self.name,
				value: messageOrValue, severity: .info, context: context,
				metadata: .init(file: _file, function: _function, line: _line, column: _column)	
			))
		}
	}
	
	public func warning(
		_ messageOrValue: Any,
		context: [String: Any] = [:],

		_file: String = #file, _function: String = #function, _line: Int = #line, _column: Int = #column
	) {
		self.listeners[.warning]?()
		for handler in self.handlers {
			handler.log(.init(
				loggerName: self.name,
				value: messageOrValue, severity: .warning, context: context,
				metadata: .init(file: _file, function: _function, line: _line, column: _column)	
			))
		}
	}
	
	public func error(
		_ messageOrValue: Any,
		context: [String: Any] = [:],

		_file: String = #file, _function: String = #function, _line: Int = #line, _column: Int = #column
	) {
		self.listeners[.error]?()
		for handler in self.handlers {
			handler.log(.init(
				loggerName: self.name,
				value: messageOrValue, severity: .error, context: context,
				metadata: .init(file: _file, function: _function, line: _line, column: _column)	
			))
		}
	}
	
	public func fatalError(
		_ messageOrValue: Any,
		context: [String: Any] = [:],

		_file: String = #file, _function: String = #function, _line: Int = #line, _column: Int = #column
	) {
		self.listeners[.fatalError]?()
		for handler in self.handlers {
			handler.log(.init(
				loggerName: self.name,
				value: messageOrValue, severity: .fatalError, context: context,
				metadata: .init(file: _file, function: _function, line: _line, column: _column)	
			))
		}
	}
	
}
extension BetterLogger {
	
	public struct Metadata {
		public let file: String
		public let function: String
		public let line: Int
		public let column: Int
	}
	
	public enum Severity {
			
		case verbose
		case info
		case warning
		case error
		case fatalError

		public var icon: String {
			switch self {
			case .verbose: return "📄"
			case .info: return "ℹ️"
			case .warning: return "⚠️"
			case .error: return "❌"
			case .fatalError: return "💥"
			}
		}
	}
	
	public struct Parameters {
		public let loggerName: String
		public let value: Any
		public let severity: BetterLogger.Severity
		public let context: [String: Any]
		public let metadata: BetterLogger.Metadata
	}
}

public protocol LoggerHandler {
	var formatter: LoggerOutputFormatter { get }
	func log(_ parameters: BetterLogger.Parameters)
}

public protocol LoggerOutputFormatter {
	func stringRepresentationFrom(_ parameters: BetterLogger.Parameters) -> String
}

// MARK: Convenient handlers

public struct ConsoleLoggerHandler: LoggerHandler {
	
	public let formatter: LoggerOutputFormatter
	
	public init(formatter: LoggerOutputFormatter) {
		self.formatter = formatter
	}
	
	public func log(_ parameters: BetterLogger.Parameters) {
		print(
			formatter.stringRepresentationFrom(parameters)
		)
	}
}

// MARK: Convenient formatters

public struct DefaultLoggerOutputFormatter: LoggerOutputFormatter {
	
	public func colored(string: String, severity: BetterLogger.Severity) -> String {
		let escape = "\u{001b}[38;5;"
		let reset = "\u{001b}[0m"
		func colorStr(_ color: String) -> String {
			return escape + color + string + reset
		}
		switch severity {
		case .verbose: return colorStr("0m")
		case .info: return colorStr("36m")
		case .warning: return colorStr("33m")
		case .error: return colorStr("31m")
		case .fatalError: return colorStr("31m")
		}
	}
	
	public func stringRepresentationFrom(_ parameters: BetterLogger.Parameters) -> String {
		
		let date = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short

		let aContext = parameters.context.isEmpty ? "" : "\n\n- Context: \n\(_stringRepresentationFrom(parameters.context))"

		let objectDescription = _stringRepresentationFrom(parameters.value)

		let p1 = """
		======================================================
		  (\(parameters.loggerName) logger)
		  === \(parameters.severity.icon) [\(parameters.severity)] \(parameters.severity.icon) - [\(dateFormatter.string(from: date))]  ===
		  ===  \(parameters.metadata.file.lastPathComponent):\(parameters.metadata.line):\(parameters.metadata.column) \(parameters.metadata.function)  ===
		
		"""
		let p2 = "\n\(objectDescription)\(aContext)\n"
		let p3 = "======================================================"
		return colored(string: p1, severity: parameters.severity) + p2 + colored(string: p3, severity: parameters.severity)
	}
}

public struct XcodeLoggerOutputFormatter: LoggerOutputFormatter {
	
	public func stringRepresentationFrom(_ parameters: BetterLogger.Parameters) -> String {
		
		let date = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short

		let aContext = parameters.context.isEmpty ? "" : "\n\n- Context: \n\(_stringRepresentationFrom(parameters.context))"

		let objectDescription = _stringRepresentationFrom(parameters.value)

		return """
		======================================================
		  (\(parameters.loggerName) logger)
		  === \(parameters.severity.icon) [\(parameters.severity)] \(parameters.severity.icon) - [\(dateFormatter.string(from: date))]  ===
		  ===  \(parameters.metadata.file.lastPathComponent):\(parameters.metadata.line):\(parameters.metadata.column) \(parameters.metadata.function)  ===
			
		\(objectDescription)\(aContext)
		
		======================================================
		"""
	}
}

public struct SimpleLoggerOutputFormatter: LoggerOutputFormatter {
	public func stringRepresentationFrom(_ parameters: BetterLogger.Parameters) -> String {
		let aContext = parameters.context.isEmpty ? "" : "\n\n- Context: \n\(_stringRepresentationFrom(parameters.context))"
		return "\(parameters.value)\(aContext)"
	}
}

// Private convenience functions

fileprivate extension String {
	var lastPathComponent: String {
		return URL(fileURLWithPath: self).lastPathComponent
	}
}

fileprivate func _stringRepresentationFrom(_ value: Any) -> String {
	let objectMirror = Mirror(reflecting: value)
	var objectDescription = ""
	if value is CustomStringConvertible || value is CustomDebugStringConvertible || objectMirror.displayStyle == .enum || objectMirror.displayStyle == .struct {
		objectDescription = String(describing: value)
	} else {
		dump(value, to: &objectDescription)
	}
	return objectDescription
}


// Public Useful extensions

public extension String {
	init(dumping value: Any?) {
		var objectDescription = ""
		dump(value, to: &objectDescription)
		self = objectDescription
	}
}
