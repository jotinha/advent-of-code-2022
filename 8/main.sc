import scala.io.Source

object Puzzle8 {

    //scan is like reduce but returns the values as it progresses through the list  
    //because we set an initial value, the list will have n+1 entries 
    def maxAlongAxis(lst: Seq[Int]) : Seq[Int] = 
        lst.scan(-1)(_ max _)
    
    def areVisibleLeft(lst: Seq[Int]) : Seq[Boolean] = 
        (lst zip maxAlongAxis(lst)).map(_>_)

    val areVisibleRight = (lst: Seq[Int]) => areVisibleLeft(lst.reverse).reverse
    
    def ors(a: Seq[Boolean], b: Seq[Boolean]) : Seq[Boolean] =
        (a zip b).map(_|_)

    def mults(a: Seq[Int], b: Seq[Int]) : Seq[Int] =
        (a zip b).map(_*_)

    def countUntil(lst: Seq[Int], cond : (Int => Boolean)): Int = lst match{
        case Nil => 0
        case x::xs if cond(x) => 1 
        case x::xs if !cond(x) => 1 + countUntil(xs, cond)
    }

    def findDistancesToBlocksRight(lst: Seq[Int]) : Seq[Int] = lst match {
        case Seq(x) => Seq(0);
        case x::xs => countUntil(xs,_ >= x) +: findDistancesToBlocksRight(xs)
    }

    val findDistancesToBlocksLeft = (lst: Seq[Int]) => findDistancesToBlocksRight(lst.reverse).reverse

    def main(args: Array[String]) = {
        val lines = Source.fromFile("input").getLines()
        val rows = lines.map(_.map(_.asDigit).toList).toSeq
        val cols = rows.transpose
 
        val visibleRows = rows.map(l => ors(areVisibleLeft(l), areVisibleRight(l)))
        val visibleCols = cols.map(l => ors(areVisibleLeft(l), areVisibleRight(l)))

        val visible = (visibleRows zip visibleCols.transpose).map(ors)
        
        val ans1 = visible.flatten.count(_ == true)

        val scoreRows = rows.map(l => mults(findDistancesToBlocksRight(l), findDistancesToBlocksLeft(l)))
        val scoreCols = cols.map(l => mults(findDistancesToBlocksRight(l), findDistancesToBlocksLeft(l)))
        val score = (scoreRows zip scoreCols.transpose).map(mults)
        
        val ans2 = score.map(_.max).max
 
        println(s"$ans1,$ans2")
    }
}

