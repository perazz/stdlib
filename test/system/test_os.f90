module test_os
    use testdrive, only : new_unittest, unittest_type, error_type, check, skip_test
    use stdlib_system, only: get_runtime_os, OS_WINDOWS, OS_UNKNOWN, OS_TYPE, is_windows

    implicit none

contains

    !> Collect all exported unit tests
    subroutine collect_suite(testsuite)
        !> Collection of tests
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest('test_get_runtime_os', test_get_runtime_os), &
            new_unittest('test_is_windows', test_is_windows) &
        ]
    end subroutine collect_suite

    subroutine test_get_runtime_os(error)
        type(error_type), allocatable, intent(out) :: error
        integer :: os

        !> Get current OS
        os = get_runtime_os()

        call check(error, os /= OS_UNKNOWN, "running on an unknown/unsupported OS")
        
    end subroutine test_get_runtime_os

    !> If running on Windows (_WIN32 macro is defined), test that the appropriate OS flag is returned
    subroutine test_is_windows(error)
        type(error_type), allocatable, intent(out) :: error
        integer :: os_cached, os_runtime
        
        call check(error, OS_TYPE()==OS_WINDOWS .eqv. is_windows(), &
                   "Cached OS type does not match _WIN32 macro presence")

    end subroutine test_is_windows


end module test_os

program tester
    use, intrinsic :: iso_fortran_env, only : error_unit
    use testdrive, only : run_testsuite, new_testsuite, testsuite_type
    use test_os, only : collect_suite

    implicit none

    integer :: stat, is
    type(testsuite_type), allocatable :: testsuites(:)
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    testsuites = [ &
        new_testsuite("os", collect_suite) &
    ]

    do is = 1, size(testsuites)
        write(error_unit, fmt) "Testing:", testsuites(is)%name
        call run_testsuite(testsuites(is)%collect, error_unit, stat)
    end do

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
        error stop
    end if
end program
