import scala.io.Source

object Puzzle8 {

    //scan is like reduce but returns the values as it progresses through the list  
    //because we set an initial value, we must remove it by doing tail
    //then we apply the set to get the unique values
    def maxAlongAxis(lst: Seq[Int]) : Seq[Int] = 
        lst.scan(0)(_ max _).tail
    
    def isVisibleOneSide(lst: Seq[Int]) : Seq[Boolean] = 
        (lst zip maxAlongAxis(lst)).map(_==_)

    def isVisibleBothSides(lst: Seq[Int]) : Seq[Boolean] =
         (isVisibleOneSide(lst) zip isVisibleOneSide(lst.reverse)).map(_|_) 

    def main(args: Array[String]) = {
        val lines = Source.fromFile("test").getLines()
        val rows = lines.map(_.map(_.asDigit))        
        
        val visibleRows = rows.map(isVisibleBothSides)
        visibleRows.foreach(println) 
        
        val ans1 = "TODO";
        val ans2 = "TODO";
        println(s"$ans1,$ans2")
    }
}

