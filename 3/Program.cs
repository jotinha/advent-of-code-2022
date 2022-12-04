using System.Diagnostics;

Console.WriteLine("Hello, World!");

string[] lines = System.IO.File.ReadAllLines(@"input");

int GetPriority(char c) {
    return (int)(c >= 'a' ? c - 'a' + 1 : c - 'A' + 27);
}

int total = 0;

foreach (string line in lines) {
    ulong[] bitmask = {0,0};

    Debug.Assert(line.Length % 2 == 0);
    int half = line.Length / 2;
    //Console.WriteLine("{0} {1}", line, half);

    for(int i = 0; i < line.Length; i++) {
        char c = line[i];
        int priority = GetPriority(c); 

        if (i == half) Console.Write('|');

        ulong bit = (ulong)1L << priority;
        
        if ((i>=half) && ((bitmask[0] & bit) != 0) && ((bitmask[1] & bit) == 0)) {
            //Console.Write("{0} ", priority);
            Console.Write("*");
            total += priority;
        }
        bitmask[i<half ? 0:1] |= bit; //set bit on either the left or right mask       
        Console.Write("{0} ",priority);
    }
    Console.Write('\n');
}

Console.WriteLine("Total priority: {0}", total); 
