import std.stdio;

import common;
import dumbknn;
import bucketknn;
import quadTree;
import kdTree;
//import your files here

void main()
{

    // //because dim is a "compile time parameter" we have to use "static foreach"
    // //to loop through all the dimensions we want to test.
    // //the {{ are necessary because this block basically gets copy/pasted with
    // //dim filled in with 1, 2, 3, ... 7.  The second set of { lets us reuse
    // //variable names.
    // writeln("dumbKNN results");
    // static foreach(dim; 1..8){{
    //     //get points of the appropriate dimension
    //     auto trainingPoints = getGaussianPoints!dim(1000);
    //     auto testingPoints = getUniformPoints!dim(100);
    //     auto kd = DumbKNN!dim(trainingPoints);
    //     writeln("tree of dimension ", dim, " built");
    //     auto sw = StopWatch(AutoStart.no);
    //     sw.start; //start my stopwatch
    //     foreach(const ref qp; testingPoints){
    //         kd.knnQuery(qp, 10);
    //     }
    //     sw.stop;
    //     writeln(dim, sw.peek.total!"usecs"); //output the time elapsed in microseconds
    //     //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
    //     //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
    // }}


    // writeln("BucketKNN results");
    // //Same tests for the BucketKNN
    // static foreach(dim; 1..8){{
    //     //get points of the appropriate dimension
    //     enum numTrainingPoints = 1000;
    //     auto trainingPoints = getGaussianPoints!dim(numTrainingPoints);
    //     auto testingPoints = getUniformPoints!dim(100);
    //     auto kd = BucketKNN!dim(trainingPoints, cast(int)pow(numTrainingPoints/64, 1.0/dim)); //rough estimate to get 64 points per cell on average
    //     writeln("tree of dimension ", dim, " built");
    //     auto sw = StopWatch(AutoStart.no);
    //     sw.start; //start my stopwatch
    //     foreach(const ref qp; testingPoints){
    //         kd.knnQuery(qp, 10);
    //     }
    //     sw.stop;
    //     writeln(dim, sw.peek.total!"usecs"); //output the time elapsed in microseconds
    //     //NOTE, I SOMETIMES GOT TOTALLY BOGUS TIMES WHEN TESTING WITH DMD
    //     //WHEN YOU TEST WITH LDC, YOU SHOULD GET ACCURATE TIMING INFO...
    // }}

    // File f = File("QuadTree.csv", "w");
    // f.writeln("QuadTree,Dim,N,K,Time");
    // foreach(N; 1..8) {
    //     auto trainingPoints = getGaussianPoints!2(N * 100000);
    //     auto testingPoints = getUniformPoints!2(100);
    //     auto qt = QuadTree(trainingPoints);
    //     foreach(k; 1..8) {{
    //         StopWatch sw = StopWatch(AutoStart.no);
    //         sw.start;
    //         foreach(r; 1..4) {
    //             foreach(const ref qp; testingPoints) {
    //                 qt.knnQuery(qp, k * 100);
    //             }
    //         }
    //         sw.stop;
    //         f.writeln("QuadTree", ",", "2", ",", N * 100000, ",", k * 100, ",", sw.peek.total!"usecs" / 300);
    //     }} 
    // } 
    // f.close();

//     File f = File("KDTree.csv", "w");
//     f.writeln("KDTree,Dim,N,K,Time");
//     static foreach(Dim; 1..8) {{
//         foreach(N; 1..8) {{
//             auto testingPoints = getUniformPoints!Dim(10);
//             auto trainingPoints = getGaussianPoints!Dim(N * 10000);
//             auto kd = KDTree!Dim(trainingPoints);
//             foreach(k; 1..11) {{
//                 StopWatch sw;
//                 sw.start;
//                 foreach(r; 1..4) {
//                     foreach(const ref qp; testingPoints) {
//                         kd.knnQuery(qp, k * 100);
//                     }
//                 }
//                 sw.stop;
//                 f.writeln("KDTree", ",", Dim, ",", N * 10000, ",", k * 100, ",", sw.peek.total!"usecs" / 300);
//         }}
//     }}
// }}
// f.close();

// File f = File("DumbKNN.csv", "w");
// f.writeln("DumbKNN,Dim,N,K,Time");
// writeln("DumbKNN results");
// static foreach(dim; 1..8) {{
//     foreach(N; 1..8) {
//         auto trainingPoints = getGaussianPoints!dim(N * 1000);
//         auto testingPoints =  getUniformPoints!dim(100);
//         auto dumb = DumbKNN!dim(trainingPoints);
//         writeln("tree of dimension ", dim, " built");
//         foreach(k; 1..11) {{
//             auto sw = StopWatch(AutoStart.no);
//             sw.start;
//             foreach(r; 1..4) {
//                 foreach(const ref qp; testingPoints) {
//                     dumb.knnQuery(qp, k * 100);
//                 }
//             }
//             sw.stop;
//             f.writeln("DumbKNN", ",", dim, ",", N * 1000, ",", k * 100, ",", sw.peek.total!"usecs" / 300);
//         }}
//     }
// }}
// f.close();

File f = File("BucketKNN.csv", "w");
f.writeln("BucketKNN,Dim,N,K,Time");
static foreach(dim; 1..5) {{
    foreach(N; 1..4) {{
        enum numTrainingPoints = 1000;
        auto trainingPoints = getGaussianPoints!dim(numTrainingPoints);
        auto testingPoints = getUniformPoints!dim(100);
        auto bucket = BucketKNN!dim(trainingPoints, cast(int)pow(numTrainingPoints/64, 1.0/dim)); //rough estimate to get 64 points per cell on average
        writeln("tree of dimension ", dim, " built");
        foreach(k; 1..6) {{
            auto sw = StopWatch(AutoStart.no);
            sw.start;
            foreach(r; 1..10) {
                foreach(const ref qp; testingPoints) {
                    bucket.knnQuery(qp, k * 100);
                }
            }
            sw.stop;
            f.writeln("BucketKNN", ",", dim, ",", N * 1000, ",", k * 100, ",", sw.peek.total!"usecs" / 300);
        }}
    }}
}}

}
