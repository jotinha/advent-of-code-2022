using System.Diagnostics;

Console.WriteLine("Hello, World!");

string[] lines = System.IO.File.ReadAllLines(@"input");

int GetPriority(char c) {
    return (int)(c >= 'a' ? c - 'a' + 1 : c - 'A' + 27);
}

ulong ToBit(int code) {
    return (ulong)1L << code;
}

ulong SetAdd(ulong bitmask, int code) {
    return bitmask | ToBit(code); 
}

bool SetContains(ulong bitmask, int code) {
    return (bitmask & ToBit(code)) != 0; 
}

int total = 0;

foreach (string line in lines) {
    ulong bitmask = 0;
    bool found = false;

    Debug.Assert(line.Length % 2 == 0);
    int half = line.Length / 2;
    //Console.WriteLine("{0} {1}", line, half);

    for(int i = 0; i < line.Length; i++) {
        char c = line[i];
        int priority = GetPriority(c); 

        if (i == half) Console.Write('|');

        if (i < half) {
            bitmask = SetAdd(bitmask, priority); //set bit on the left side
        } else if (SetContains(bitmask,priority) && !found) {
            //Console.Write("{0} ", priority);
            Console.Write("*");
            total += priority;
            found = true;
        }
        Console.Write("{0} ",priority);
    }
    Console.Write('\n');
}

Console.WriteLine("Total priority: {0}", total); 
