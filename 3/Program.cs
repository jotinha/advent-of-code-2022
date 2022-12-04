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

int total_a = 0;
int total_b = 0;

ulong left = 0;
ulong line1 = 0;
ulong line2 = 0;
bool foundInLine, foundInGroup;

for (int l=0; l < lines.Length; l++) {
    string line = lines[l];
    left = 0;
    foundInLine = false;
    if (l % 3 == 0) {
        foundInGroup = false;
        line1 = 0;
        line2 = 0;
    }
    int half = line.Length / 2;

    for(int i = 0; i < line.Length; i++) {
        char c = line[i];
        int priority = GetPriority(c); 

        //if (i == half) Console.Write('|');

        if (i < half) {
            left = SetAdd(left, priority); //set bit on the left side
        } else if (SetContains(left,priority) && !foundInLine) {
            //Console.Write("{0} ", priority);
            //Console.Write("*");
            total_a += priority;
            foundInLine = true;
        }
        //Console.Write("{0} ",priority);
    }
    //Console.Write('\n');
}

Console.WriteLine("{0},{1}",total_a,total_b); 
