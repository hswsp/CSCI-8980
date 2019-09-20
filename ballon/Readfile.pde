import java.io.FileReader;

String[] readFile(String pathname) {

  String[] lines = loadStrings(pathname);
  //println("there are " + lines.length + " lines");
  //for (int i = 0; i < lines.length; i++) {
  //  println(lines[i]);
  //}
  return lines;
}
void ShowText(String[] lines)
{
  int lineX = 10;
  int lineY = height/4;
  int lineH = 38;
  //TextJustification tj = new TextJustification();
  for (int i = 0; i < lines.length; i++) {
    String Line = lines[i];
    //ArrayList<String> result = tj.fullJustify(Line, 20);
    fill(51, 0, 25);
    textSize(lineH);
    textAlign(LEFT);
    //textLeading(35);
    text(Line, lineX, lineY+i*(lineH+30));
  }
}

public class TextJustification {
  // T(len(words)*L), S(len(words)*L)
  public ArrayList<String> fullJustify(String[] words, int L) {
    ArrayList<String> res = new ArrayList<String>();

    int len=0;   // count current line char length
    int start=0;  // count the start index of the word in current line

    for (int i=0; i<words.length; i++) {
      len +=words[i].length();
      if (len+i-start>L) { //i-start means the least spaces we need between words
        res.add(justify(words, start, i-1, len-words[i].length(), L));
        len=words[i].length(); // reset len
        start=i;
      }
    }
    // last line
    if (len>0) res.add(justify(words, start, words.length-1, len, L));
    if (res.size()==0) res.add(stuffSpaces(L));
    return res;
  }
  // generate a string of Length L, containing words[start...end] inclusively
  // T(L), S(L)
  private String justify(String[] words, int start, int end, int total, int L) {
    StringBuilder sb = new StringBuilder();
    if (end==start || end==words.length-1) { // single word or last line
      while (start<end) sb.append(words[start++]).append(" ");
      sb.append(words[end]).append(stuffSpaces(L-sb.length()));
    } else {
      int space=(L-total)/(end-start);
      int extra=(L-total)%(end-start);
      while (start<end) {
        sb.append(words[start++]);
        sb.append(stuffSpaces(space));
        if (extra>0) {
          sb.append(" ");
          extra--;
        }
      }
      sb.append(words[end]);
    }
    return sb.toString();
  }

  private String stuffSpaces(int n) {
    if (n==0) return "";
    StringBuilder sb = new StringBuilder();
    while (n-->0) sb.append(" ");
    return sb.toString();
  }
}  
