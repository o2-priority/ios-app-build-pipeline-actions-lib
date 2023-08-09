import Foundation

public final class Version<T>: NSObject where T: RedactableTextOutputStream {
    
    private var textOutputStream: T
    
    public init(textOutputStream: T) {
        self.textOutputStream = textOutputStream
    }
    
    public func version() {
        print("3.2.0-alpha.2", to: &textOutputStream)
    }
}
