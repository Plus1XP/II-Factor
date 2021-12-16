import Foundation

extension String {

        /// Returns a new string made by removing spaces from both ends of the String.
        /// - Returns: A new string made by removing spaces from both ends of the String.
        @available(* , deprecated, renamed: "trimming")
        func trimmingSpaces() -> String {
                trimmingCharacters(in: CharacterSet(charactersIn: " "))
        }
    
        /// aka. `String.init()`
        static let empty: String = ""

         /// Six zeros
        static let zeros: String = "000000"

        /// Returns a new string made by removing `.whitespacesAndNewlines` from both ends of the String.
        /// - Returns: A new string made by removing `.whitespacesAndNewlines` from both ends of the String.
        func trimmed() -> String {
                return trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
        /// Returns a new string made by removing `.whitespaces` from within the String.
        /// - Returns: A new string made by removing `.whitespaces` from within the String.
        func removeSpaces() -> String {
            var characters = String(self)
            var index = 0
            characters.forEach { character in
                if character.isWhitespace {
                    characters.remove(at: characters.index(characters.startIndex, offsetBy: index))
                    index -= 1
                }
                index += 1
            }
            return String(characters)
        }
}

extension Optional where Wrapped == String {

        /// Not nil && not empty
        var hasContent: Bool {
                switch self {
                case .none:
                        return false
                case .some(let value):
                        return !value.isEmpty
                }
        }
}
