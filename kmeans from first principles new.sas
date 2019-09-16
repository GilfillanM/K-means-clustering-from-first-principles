
* 3 dimensional data changed to 2 dimensional;
data a ;
input X1 X2	X3 ;
keep X1 X2;
cards;
25.431565	25.933835	37.24979
23.337532	33.238455	39.632566
12.946236	31.090874	41.410102
11.969851	20.15965	35.350383
14.848399	22.939167	36.585108
18.096521	22.285654	40.311387
15.983284	35.065821	46.766173
20.580939	28.317143	41.124029
19.602993	26.171693	35.882251
4.3317016	29.345467	37.910276
19.086121	26.295734	30.270269
13.548145	25.079301	37.958955
118.21118	135.7007	144.21129
116.95557	132.1643	139.54306
119.87893	126.80532	140.47414
126.91946	132.77775	139.48535
125.7058	124.3089	134.14785
117.85024	128.38386	136.07865
129.14882	131.11702	141.80763
124.01972	134.28581	138.9426
119.44251	130.94937	139.70347
116.28171	130.44813	146.72788
120.91516	129.20598	142.62789
117.39883	125.84577	133.06846
66.004697	76.209273	86.272148
67.442937	79.967425	87.070665
62.346243	74.295596	85.055967
73.360764	81.442888	90.72273
77.058177	82.016948	87.103163
64.71757	88.460159	93.582392
70.499663	85.34535	90.899389
61.26967	80.649116	92.365147
80.102074	83.83776	91.764146
77.419293	81.371541	90.413738
70.364107	77.508103	87.324323
66.789004	88.558624	92.471582
; 

run;

proc print data=a;
run;

data a; 
set a  (firstobs=6 obs=15);
run ;

proc gplot data=a;
plot  x2*x1;
run;

* Convert data into matrix;
proc iml;
use a;
read all into m;
print m;


* Sample randomly the number of clusters as number of data points;
call randseed(1234);
k = 2;
amount_of_var = 2;
print k;
s = sample(m, {2 2}, "WOR");
print s;


* Concatenate sampled datapoints(centroids) to the rest of the data;
new_m = m // s;
n = nrow(new_m);
print new_m[rowname=(char(1:n))];


extract_t_old = j(k,n,0);
diff=11111;

*Create a do loop;
do jj = 1 to 10   while (diff ^= 0)    ; *until extract_t=extract_t;
print "***********************" ;
print "Iteration: " jj ;

* Create a distance matrix for new_m;
distance = distance(new_m);
print distance[colname=(char(1:n)) rowname=(char(1:n))];

* Take s(two centroids) from the distance matrix;
extract = distance[,n-k+1:n];
extract_t = extract`;
print extract_t[colname=(char(1:n)) rowname=(char(n-k+1:n))];

* Identify the minimum in each row(make it 1) and replace the rest with zero's;
col_min = extract_t[><,] ;
idx = loc(extract_t ^= col_min);
extract_t[idx] = 0;
print extract_t[colname=(char(1:n)) rowname=(char(n-k+1:n))];
idx = loc(extract_t ^= 0);
extract_t[idx] = 1;
print extract_t[colname=(char(1:n)) rowname=(char(n-k+1:n))];

* Get observations alone that are in the first and second cluster respectively and get the average of each cluser;
do i=1 to k;
	average_m = average_m // mean(((extract_t[i,] // extract_t[i,])` # new_m));
end;

new_m = m // average_m;
print average_m new_m;

* update new_m with new centroids and start process again;
* When extract_t repeats itself iteration can stop and covergence is reached;


free average_m ;

print "qqqqqqqqqqqqqqqqqqqqqqqqqqq" , extract_t_old extract_t ;

if extract_t_old  = extract_t then diff=0 ; 
extract_t_old = extract_t ;

print diff ;

end;
quit;
