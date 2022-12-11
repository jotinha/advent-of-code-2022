import scala.io.Source

object Puzzle8 {

    //scan is like reduce but returns the values as it progresses through the list  
    //because we set an initial value, the list will have n+1 entries 
    def maxAlongAxis(lst: Seq[Int]) : Seq[Int] = 
        lst.scan(-1)(_ max _)
    
    def areVisibleOneSide(lst: Seq[Int]) : Seq[Boolean] = 
        (lst zip maxAlongAxis(lst)).map(_>_)

    val areVisibleLeft = (lst: Seq[Int]) => areVisibleOneSide(lst)
    val areVisibleRight = (lst: Seq[Int]) => areVisibleOneSide(lst.reverse).reverse

    def areVisibleBothSides(lst: Seq[Int]) : Seq[Boolean] = 
         (areVisibleLeft(lst) zip areVisibleRight(lst)).map(_|_) 

    def main(args: Array[String]) = {
        val lines = Source.fromFile("test").getLines()
        val rows = lines.map(_.map(_.asDigit))        
 
        val visibleRows = rows.map(areVisibleBothSides)
        visibleRows.foreach(println) 
        
        val ans1 = "TODO";
        val ans2 = "TODO";
        println(s"$ans1,$ans2")
    }
}

