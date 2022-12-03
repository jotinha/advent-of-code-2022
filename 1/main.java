import java.io.*;

class Puzzle1 {
	public static void main(String[] args) throws IOException {

		FileReader fr = new FileReader("input");
		BufferedReader br = new BufferedReader(fr);
		String line;
		
		int calories = 0;
		int maxCalories = 0;

		while ((line = br.readLine()) != null) {

			if (line.trim().isEmpty()) {
				calories = 0;
			} else {
				calories += Integer.parseInt(line.trim());				
				if (calories > maxCalories) {
					maxCalories = calories;
				}
			}
			// debug
			System.out.printf("%s %d %d\n", line, calories, maxCalories);
		}
		System.out.printf("%d\n", maxCalories);
	}
}	
