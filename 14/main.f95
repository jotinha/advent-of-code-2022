program hello
    implicit none
    integer :: world(520,10) 
    call buildworld(world)

contains
    subroutine buildworld(world)
        implicit none
        integer, intent(inout) :: world(:,:)
        character (len=128) :: line
        integer :: io
        integer :: points(256)
        integer :: n,i 
        
        world = 0
        open(1, file='test', status='old', action='read')
        do
            read(1,"(A70)",iostat=io) line
            if (io/= 0) exit
            n = parse(line, points) 
            do i=1,n+1,2
                call fillline(world,points(i:i+1),points(i+2:i+3))
                !print *,points(i),points(i+2),points(i+1),points(i+3)
                 
            end do
            !print *,"next"
            !print *, n, points(:n*2)
        end do
        call draw(transpose(world))
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

    subroutine fillline(world,p1,p2)
        implicit none
        integer, dimension(2), intent(in) :: p1,p2
        integer, dimension(:,:), intent(inout) :: world
        integer :: i1,i2,j1,j2 
        i1 = min(p1(1),p2(1))
        i2 = max(p1(1),p2(1))
        j1 = min(p1(2),p2(2))
        j2 = max(p1(2),p2(2))
        world(i1:i2,j1:j2) = 1

    end subroutine

    subroutine draw(world)
        implicit none
        integer, dimension(:,:), intent(in) :: world
        integer :: i,j

        open(2, file="world", action="write")
        do i = 1,size(world,1)
            do j=1,size(world,2)
                write(2,fmt='(1a)', advance="no") pict(world(i,j)) 
            end do
            write (2,*) ""
        end do
        close(2)
    end subroutine

    character function pict(pixel)
        implicit none
        integer, intent(in) :: pixel        

        select case (pixel)
            case (0) 
                pict = '.'
            case (1) 
                pict = '#'
            case (2) 
                pict = '@'
            case default
                pict = '?'
        end select 
    end function pict
    
end program
