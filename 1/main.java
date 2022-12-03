import java.io.*;

class Puzzle1 {
	public static void main(String[] args) throws IOException {

		FileReader fr = new FileReader("input");
		BufferedReader br = new BufferedReader(fr);
		String line;
		
		int elf = 1;
		int calories = 0;
		int maxCalories = 0;
		int bestElf = 0;

		while ((line = br.readLine()) != null) {

			if (line.trim().isEmpty()) {
				elf += 1;
				calories = 0;
			} else {
				calories += Integer.parseInt(line.trim());				
				if (calories > maxCalories) {
					maxCalories = calories;
					bestElf = elf;
				}
			}
			// debug
			System.out.printf("%s %d %d %d\n", line, calories, maxCalories, bestElf);
		}
		System.out.printf("%d %d\n", maxCalories, bestElf);
	}
}	
