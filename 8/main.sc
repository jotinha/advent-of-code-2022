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
    
    def ors(a: Seq[Boolean], b: Seq[Boolean]) : Seq[Boolean] =
        (a zip b).map(_|_)

    def main(args: Array[String]) = {
        val lines = Source.fromFile("input").getLines()
        val rows = lines.map(_.map(_.asDigit)).toSeq
        val cols = rows.transpose
 
        val visibleRows = rows.map(l => ors(areVisibleLeft(l), areVisibleRight(l)))
        val visibleCols = cols.map(l => ors(areVisibleLeft(l), areVisibleRight(l)))

        val visible = (visibleRows zip visibleCols.transpose).map(ors)
        
        val count = visible.flatten.count(_ == true)

        val ans1 = count;
        val ans2 = "TODO";
        println(s"$ans1,$ans2")
    }
}

