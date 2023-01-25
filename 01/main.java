import java.io.*;
import java.lang.Math;
import java.util.Arrays;

class Main {
    public static void main(String[] args) throws IOException {

        FileReader fr = new FileReader("input");
        BufferedReader br = new BufferedReader(fr);
        String line;
        
        int calories = 0;
        int maxCalories = 0;
        int[] topCalories = new int[3];

        while ((line = br.readLine()) != null) {

            if (line.trim().isEmpty()) {
                calories = 0;
            } else {
                calories += Integer.parseInt(line.trim());                
                if (calories > topCalories[0]) {
                    topCalories[0] = calories;
                    Arrays.sort(topCalories);
                }
            }
            //System.out.printf("%s %d %s\n", line, calories, Arrays.toString(topCalories));
        }
        
        System.out.printf("%d,%d\n", topCalories[2], Arrays.stream(topCalories).sum());
    }
}    
