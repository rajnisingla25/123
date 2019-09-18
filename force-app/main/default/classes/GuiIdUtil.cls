public class GuiIdUtil {
       public static String NewGuidId(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h;
    }
  }