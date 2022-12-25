program hello
    implicit none
    integer :: world(520,520) 
    call buildworld(world)

contains
    subroutine buildworld(world)
        implicit none
        integer, intent(inout) :: world(:,:)
        character (len=128) :: line
        integer :: io
        integer :: points(256)
        integer :: n

        open(1, file='test', status='old', action='read')
        do
            read(1,"(A70)",iostat=io) line
            if (io/= 0) exit
            n = parse(line, points) 
            print *, n, points(:n*2)
        end do
        close(1)
    end subroutine 

    recursive function parse(line, points) result(n)
        implicit none
        character (len=*), intent(inout) :: line
        integer, dimension(:) :: points
        integer :: n
        integer :: i
        n = 1 
        
        i = index(line,' -> ') 
        read(line,*) points(1:2)
        if (i==0) return 

        line = line(i+4:)    
        n = 1 + parse(line, points(3:))
    
    end function


end program
