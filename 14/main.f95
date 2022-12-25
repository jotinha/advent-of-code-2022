program hello
    implicit none
    integer :: world(1024,256) 
    integer :: ans1,ans2,jfloor

    call buildworld(world, jfloor)
    
    ans1 = simulate(world, 500,0)
    call draw(transpose(world))
  
    world(:,jfloor) = 1
    ans2 = ans1 + simulate(world,500,0) + 1 !pick up where we left off  
    !+1 because we need to count the one at the origin

    print '(2(i0:","))', ans1,ans2

    call draw(transpose(world))
contains
    subroutine buildworld(world, jfloor)
        implicit none
        integer, intent(inout) :: world(:,:)
        integer, intent(out) :: jfloor
        character (len=2048) :: line
        integer :: io
        integer :: points(2048)
        integer :: n,i 
        
        world = 0
        jfloor = 0
        open(1, file='input', status='old', action='read')
        do
            read(1,"(A)",iostat=io) line
            if (io/= 0) exit
            n = parse(line, points) 
            do i=1,(n-1)*2,2
                call fillline(world,points(i:i+1),points(i+2:i+3))
                !print *,points(i),points(i+2),points(i+1),points(i+3)
                jfloor = max(jfloor, points(i+1),points(i+3))
            end do
            !print *, n, points(:n*2)
        end do
        close(1)
        jfloor = jfloor + 2
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
        n = n + parse(line, points(3:))
    
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
                pict = 'o'
            case default
                pict = '?'
        end select 
    end function pict

    recursive function fall(world, i, j) result(cont)
        implicit none
        integer, intent(inout) :: world(:,:)
        integer, intent(in) :: i, j ! sand position
        logical :: cont ! true if in rest, false if it reached void 
      
        if ((j+1) > size(world,2)) then
            cont = .FALSE. !void 
            !print *,"fell down in void at", i,j
        elseif (world(i,j+1) == 0) then
            cont = fall(world,i,j+1) ! fall down 
        elseif (world(i-1,j+1) == 0) then
            cont = fall(world,i-1,j+1) ! fall down left
        elseif (world(i+1,j+1) == 0) then
            cont = fall(world,i+1,j+1) ! fall down right
        elseif (j==0) then ! we have no where else to go and we're at the start
            cont = .FALSE.
        else ! at rest
            cont = .TRUE.
            world(i,j) = 2
        end if

    end function 

    integer function simulate(world,starti,startj)
        implicit none
        integer, intent(inout) :: world(:,:)
        integer, intent(in) :: starti,startj
        
        simulate = 0 
        do while (fall(world,starti,startj)) 
            simulate = simulate + 1
        end do
        
    end function 
end program
