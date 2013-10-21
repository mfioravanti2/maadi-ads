import java.util.*;


public class CustomStack extends Stack {



    public synchronized String toString() {

        String format = "[";
        for(int i = 0; i < this.elementCount; i++) {
            format+="\"";
            format+= (this.elementData[i] + "\"");
            if(i < (this.elementCount-1)) {
                format+=", ";
            }
        }

        return format+"]";
    }

}