use v6.c;
use Test;

#
# Copyright © 2018 Joelle Maslak
# All Rights Reserved - See License
#

use DateTime::Monotonic;

subtest 'Basic usage', {
    my $time = DateTime::Monotonic.new;
    ok $time.defined, "Time object defined";
    ok $time ~~ DateTime::Monotonic, "Time object is proper type";

    note "# Monotonic Support: {$time.has-monotonic-support}";
    note "# Kernel.name      : {Kernel.new.name}";

    is $time.has-monotonic-support.defined, True, "Interface provides monotonic data";
    
    my $start = $time.seconds;
    sleep 1;
    my $end   = $time.seconds;

    is $start, 0, "Start time correct";
    ok $start ~~ Numeric, "Start time is proper type";
    is $end.defined, True, "End time defined";
    ok $end ~~ Numeric, "End time is proper type";

    note "# START: $start";
    note "# END  : $end";

    ok ($end - $start) ≥ 1,  "Time moves forward";
    ok ($end - $start) ≤ 60, "Time doesn't move forward too much";
    done-testing;
}

subtest 'Syscall', {
    my $time = DateTime::Monotonic.new(:use-syscall);
    ok $time.defined, "Time object defined";
    ok $time ~~ DateTime::Monotonic, "Time object is proper type";

    is $time.use-syscall, True, "Syscall interface enabled";
    is $time.testing-clock-time.defined, False, "Testing clock time defaults to Nil";

    $time.testing-clock-time = 5555;
    my $start = $time.seconds;

    $time.testing-clock-time = 5557;
    my $end   = $time.seconds;

    is $start, 0, "Start time corect";
    ok $start ~~ Numeric, "Start time is proper type";
    is $end, 2, "End time correct";
    ok $end ~~ Numeric, "End time is proper type";

    $start = $end;
    $time.testing-clock-time = 5000;
    dies-ok { $end = $time.seconds }, "Error thrown if time goes backwards";

    $time.testing-clock-time = 5558;
    lives-ok { $end = $time.seconds }, "Error not thrown on time";

    is $end, 3, "End time is correct";
    ok $end ~~ Numeric, "End time still proper type";

    done-testing;
}

subtest 'Fallback', {
    my $time = DateTime::Monotonic.new(:!use-syscall);
    ok $time.defined, "Time object defined";
    ok $time ~~ DateTime::Monotonic, "Time object is proper type";

    is $time.use-syscall, False, "Syscall interface diabled";
    is $time.testing-clock-time.defined, False, "Testing clock time defaults to Nil";

    $time.testing-clock-time = 5555;
    my $start = $time.seconds;

    $time.testing-clock-time = 5557;
    my $end   = $time.seconds;

    is $start, 0, "Start time corect";
    ok $start ~~ Numeric, "Start time is proper type";
    is $end, 2, "End time correct";
    ok $end ~~ Numeric, "End time is proper type";

    $start = $end;
    $time.testing-clock-time = 5000;
    lives-ok { $end = $time.seconds }, "Error not thrown if time goes backwards";
    is $end, 2, "End time remains same";
    ok $end ~~ Numeric, "End time still proper type";
    
    $time.testing-clock-time = 5558;
    lives-ok { $end = $time.seconds }, "Error not thrown on time";

    is $end, 560, "End time is correct";
    ok $end ~~ Numeric, "End time still proper type";

    done-testing;
}

done-testing;
