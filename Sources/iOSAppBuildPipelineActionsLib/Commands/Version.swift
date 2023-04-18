import Foundation

public final class Version<T>: NSObject where T: RedactableTextOutputStream {
    
    private var textOutputStream: T
    
    public init(textOutputStream: T) {
        self.textOutputStream = textOutputStream
    }
    
    public func version() {
        print("2.0.0", to: &textOutputStream)
    }
}
