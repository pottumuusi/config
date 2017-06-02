public class HelloExample {
    static {
        System.loadLibrary("hello");
    }

    private native void helloPrint();

    public static void main(String[] args) {
        new HelloExample().helloPrint();
    }
}
