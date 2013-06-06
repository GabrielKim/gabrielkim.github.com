a:6:{i:0;a:3:{i:0;s:14:"document_start";i:1;a:0:{}i:2;i:0;}i:1;a:3:{i:0;s:6:"p_open";i:1;a:0:{}i:2;i:0;}i:2;a:3:{i:0;s:6:"plugin";i:1;a:4:{i:0;s:25:"syntaxhighlighter3_syntax";i:1;a:3:{i:0;s:3:"sxh";i:1;s:4:"c++;";i:2;s:10696:"
#include "StdAfx.h"
#include "ImMouse.h"

#include "DefLibGR.h"
#include "DefLibRGB.h"
#include "Alg.h"
#include "Converter.h"
#include "Filter.h"
#include "Geometry.h"

void DefLibHistogram(DefLibGR& dib, float histo[256]){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	BYTE** ptr = dib.GetPtr();

	int temp[256];
	memset(temp, 0, sizeof(int)*256);
	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++) temp[ptr[j][i]]++;

	float area = (float)w*h;
	for(register int i = 0; i < 256; i++) histo[i] = temp[i] / area;
}
//
void DefLibHistEqual(DefLibGR& dib){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	float hist[256];
	DefLibHistogram(dib, hist);

	double cdf[256] = {0.0,};
	cdf[0] = hist[0];
	for(register int i = 1; i < 256; i++) cdf[i] = cdf[i-1] + hist[i];

	BYTE** ptr = dib.GetPtr();

	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++)	ptr[j][i] = (BYTE)limit(cdf[ptr[j][i]]*255);
}

void DefLibColorHistEqual(DefLibGR& dib){
	DefLibGR dibY, dibU, dibV;
	DefLibFilterColorSplitYUV(dib, dibY, dibU, dibV);

	DefLibHistEqual(dibY);

	DefLibFilterColorCombineYUV(dibY, dibU, dibV, dib);
	dibY.Destroy();
	dibU.Destroy();
	dibV.Destroy();
}

void DrawTraceLine(DefLibGR& dib, ContourPoints cp){
	DefLibRGB** ptr = dib.GetRGBPtr();
	
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.

	if(cp.num > 0){
		
		for(register int i=0; i<cp.num; i++){
			ptr[cp.y[i]][cp.x[i]].r = 0;
			ptr[cp.y[i]][cp.x[i]].g = 0;
			ptr[cp.y[i]][cp.x[i]].b = 0;
		}
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].r = 0;
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].g = 0;
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].b = 0;
		for(register int j=0; j<8; j++)
			if((cp.miny + (cp.maxy-cp.miny)/2 + dy[j] >= 0 && cp.miny + (cp.maxy-cp.miny)/2 + dy[j] < h)
				&& (cp.minx + (cp.maxx-cp.minx)/2 + dx[j] >= 0 && cp.minx + (cp.maxx-cp.minx)/2 + dx[j] < w)){
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].r = 0;
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].g = 0;
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].b = 0;
			}
	}
}

void DefLibGoTracePoint(DefLibGR& dib, GoingTrace& gt, int x, int y){
	DefLibRGB** ptr = dib.GetRGBPtr();

	int w = dib.GetWidth();
	int h = dib.GetHeight();

	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.
	
	if(gt.cnt==0){
		gt.minx = INFIN;
		gt.miny = INFIN;
		gt.maxx = 0;
		gt.maxy = 0;
	}
	
	gt.x[gt.cnt] = x;
	gt.y[gt.cnt++] = y;

	if(gt.minx > x) gt.minx = x;
	if(gt.miny > y) gt.miny = y;
	if(gt.maxx < x) gt.maxx = x;
	if(gt.maxy < y) gt.maxy = y;

	// 추적선을 바탕으로 경계선까지 함께 화면에 그려준다.
	for(register int i=0; i<gt.cnt; i++){
		ptr[gt.y[i]][gt.x[i]].r = 0;
		ptr[gt.y[i]][gt.x[i]].g = 0;
		ptr[gt.y[i]][gt.x[i]].b = 0;
		// 자취선은 조금더 굵은선..
		for(register int j=0; j<8; j++)
			if((gt.y[i] + dy[j] >= 0 && gt.y[i] + dy[j] < h)
				&& (gt.x[i] + dx[j] >= 0 && gt.x[i] + dx[j] < w)){
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].r = 0;
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].g = 0;
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].b = 0;
			}
	}
	

	for(register int i=gt.minx; i<gt.maxx; i++){
		ptr[gt.miny][i].r = 0;
		ptr[gt.miny][i].g = 0;
		ptr[gt.miny][i].b = 0;

		ptr[gt.maxy][i].r = 0;
		ptr[gt.maxy][i].g = 0;
		ptr[gt.maxy][i].b = 0;
	}

	for(register int i=gt.miny; i<gt.maxy; i++){
		ptr[i][gt.minx].r = 0;
		ptr[i][gt.minx].g = 0;
		ptr[i][gt.minx].b = 0;

		ptr[i][gt.maxx].r = 0;
		ptr[i][gt.maxx].g = 0;
		ptr[i][gt.maxx].b = 0;
	}
}

void DefLibGoTraceMatchingAlphabet(GoingTrace& gt){
	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.
	gt.matchpoints = 32767;
	int w = gt.maxx-gt.minx+1;
	int h = gt.maxy-gt.miny+1;
	int kw = gt.maxx-gt.minx+1;
	int kh = gt.maxy-gt.miny+1;
	DefLibGR dib;
	dib.CreateRGBImage(w,h);
	DefLibRGB** ptr = dib.GetRGBPtr();
	// 여기가 좀 오래 걸릴것 같다..

	// 총 8방향에 대고 그린다 이유는 간단하다, 축소의 경우를 놓고 보면,
	// 축소할때 단면적이 작기 때문에 선이 모조리 사라지는 수가 생긴다. 그러므로 크게 점을 찍어주고
	// 후에 가우시안 필터 처리해준다.
	for(register int i=0; i<gt.cnt; i++){
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].r = 0;
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].g = 0;
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].b = 0;
		// 절대 외곽선이 넘어가게 칠해지면 안되므로 다음과 같은 조치를 취한다.
		for(register int j=0; j<8; j++)
			if(((gt.y[i]-gt.miny) + dy[j] >= 0 && (gt.y[i]-gt.miny) + dy[j] < h)
				&& ((gt.x[i]-gt.minx) + dx[j] >= 0 && (gt.x[i]-gt.minx) + dx[j] < w)){
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].r = 0;
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].g = 0;
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].b = 0;
			}
	}

	int isBlankLineX[SCR_WIDTH] = {0,};
	int isBlankLineY[SCR_HEIGHT] = {0,};
	int BLcntX=0;
	int BLcntY=0;
	
	// 여기서부터 공백을 없에주기위한 함수. 프레임이 끊겨서 생기는 현상 방지.
	// 그렇게 오래 처리 되지 않음.
	for(register int j=0; j<h; j++)
		for(register int i=0; i<w; i++)
			if(ptr[j][i].r == 0 && ptr[j][i].g == 0 && ptr[j][i].b == 0){
				isBlankLineY[j] = 1;
				break;
			}

	for(register int i=0; i<w; i++)
		for(register int j=0; j<h; j++)
			if(ptr[j][i].r == 0 && ptr[j][i].g == 0 && ptr[j][i].b == 0){
				isBlankLineX[i] = 1;
				break;
			}

	for(register int i=0; i<h; i++)
		if(isBlankLineY[i] == 0){
			for(register int j=i; j<h-1; j++)
				for(register int k=0; k<w; k++){
					ptr[j][k].r = ptr[j+1][k].r;
					ptr[j][k].g = ptr[j+1][k].g;
					ptr[j][k].b = ptr[j+1][k].b;
				}
			kh--;
		}

	for(register int i=0; i<w; i++)
		if(isBlankLineX[i] == 0){
			for(register int j=i; j<w-1; j++)
				for(register int k=0; k<h; k++){
					ptr[k][j].r = ptr[k][j+1].r;
					ptr[k][j].g = ptr[k][j+1].g;
					ptr[k][j].b = ptr[k][j+1].b;
				}
			kw--;
		}

	DefLibGR bak;

	bak.CreateRGBImage(kw,kh);

	DefLibRGB** bptr = bak.GetRGBPtr();

	for(register int j=0; j<kh; j++)
		for(register int i=0; i<kw; i++){
			bptr[j][i].r = ptr[j][i].r;
			bptr[j][i].g = ptr[j][i].g;
			bptr[j][i].b = ptr[j][i].b;
		}

	// 또한 없어지는것을 방지하기 위해 계속 노력해준다.. ㅡㅡ;;
		for(register int j=0; j<kh; j++)
			for(register int i=0; i<kw; i++){
				if(ptr[j][i].r==0){
					for(register int k=0; k<8; k++){
						if((j + dy[k] >= 0 && j + dy[k] < kh) && (i + dx[k] >= 0 && i + dx[k] < kw)){
							bptr[j+dy[k]][i+dx[k]].r = 0;
							bptr[j+dy[k]][i+dx[k]].g = 0;
							bptr[j+dy[k]][i+dx[k]].b = 0;
						}
					}
				}
			}

	// 여기까지가 공백 없에기..

	// 조합 : 3차 회선 보간 + 가우시안.

	// 가장 효율적인 조합으로 나타났다.

	// 이제 선이 조금은 굵어 졌으므로 가우시안 필터를 적용해보자.
	// 그런데 가우시안 그렇게 효율적이지는 못한듯.. 대략 가우시안 2.2정도에
	// 640 * 480 기준에 그려진 3줄이 지워지지 않는 최적의 수.

	// 여기서부터는 그림 축소.. 혹은 작으면 확대..

	// 640 * 480은.. 일단.
	// 640 * 480 이미지 -> 가우시안 -> 160 * 120 -> 가우시안 -> 17 * 17 이런 순서임.
	// 320 * 240도 마찬가지.. ㅎㅎ
	// 320 * 240 이미지 -> 가우시안 -> 160 * 120 -> 가우시안 -> 17 * 17 이런 순서임.

	if(kh<61 && kw<61){
		//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
		DefLibResizeCubic(bak,17,17);
	}
	else{
		if(kh>=240 && kw >=320){
			//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
			DefLibResizeCubic(bak,160,120);
		}
		//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
		DefLibResizeCubic(bak,17,17);
	}

	DefLibRGB** cptr = bak.GetRGBPtr();

	// 여기 까지 해주면 남는것은 흰색과, 오로지 다른색 뿐이다.

	// 이제 포인트 매치만 남음.
	char programpath[_MAX_PATH];
	GetCurrentDirectory( _MAX_PATH, programpath);

	for(register int i=0; i<26; i++){
		CString cs;
		cs.Format("%s\\Alpha\\%d.bmp",programpath,i+1);

		int scnt = 0;
		int pcnt = 0;
		DefLibGR Alphabet;
		Alphabet.Load((LPCTSTR)cs);

		DefLibRGB** Aptr = Alphabet.GetRGBPtr();

		for(register int j=0; j<17; j++)
			for(register int k=0; k<17; k++){
				if(Aptr[j][k].r == 255) pcnt++;
				if(Aptr[j][k].r != 255 && cptr[j][k].r != 255) scnt++;
			}

		int MatchtoX = 17*17-pcnt;
		int makeY = MatchtoX-scnt;
		if(makeY<gt.matchpoints){
			gt.matchpoints = makeY;
			gt.AlphabetNum = i;
		}
		/*
		if(scnt>gt.matchpoints){
			gt.matchpoints = scnt;
			gt.AlphabetNum = i;
		}*/
		Alphabet.Destroy();
	}

	// 7514번 루프 돔. 이게 훨씬 빠름.
	dib.Destroy();
	bak.Destroy();
}

// 이 알고리즘 책 참고. 대체 뭔지 기억이 안남.(10/05/27)
ContourPoints DefLibCTracing(DefLibGR& dib){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	// RGB영상의 binary가 들어오므로 RGB에서 보여주기 위하여 RGB좌표 처리.
	// 모든 값이 같으므로 r에대해서만 처리한다.

	DefLibRGB** ptr = dib.GetRGBPtr();

	int x, y, nx, ny;
	int dold, d, cnt;
	int dir[8][2] = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};

	ContourPoints cp;
	cp.num = 0;

	cp.minx = INFIN;
	cp.miny = INFIN;
	cp.maxx = 0;
	cp.maxy = 0;

	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++){
			if(ptr[j][i].r == 0 || ptr[j][i].g == 0 || ptr[j][i].b == 0){
				x = i; y = j;
				dold = d = cnt = 0;

				while(1){
					nx = x + dir[d][0];
					ny = y + dir[d][1];
					
					if(nx < 0 || nx >= w || ny < 0 || ny >= h || 
						(ptr[ny][nx].r != 0 && ptr[ny][nx].g != 0 && ptr[ny][nx].b != 0)){
						if(++d > 7) d = 0;
						cnt++;

						if( cnt >= 8 ){
							cp.x[cp.num] = x;
							cp.y[cp.num] = y;
							if(cp.minx > x) cp.minx = x;
							if(cp.miny > y) cp.miny = y;
							if(cp.maxx < x) cp.maxx = x;
							if(cp.maxy < y) cp.maxy = y;
							cp.num++;
							break;
						}
					}
					else{
						cp.x[cp.num] = x;
						cp.y[cp.num] = y;
						cp.num++;

						if(cp.minx > x) cp.minx = x;
						if(cp.miny > y) cp.miny = y;
						if(cp.maxx < x) cp.maxx = x;
						if(cp.maxy < y) cp.maxy = y;

						if(cp.num >= MAX_CONTOUR) break;

						x = nx;	y = ny;
						cnt = 0; dold = d;
						d = ( dold + 6 ) % 8;
					}
				

					if( x == i && y == j && d == 0 ) break;
				}
				i = w; j = h;
			}
		}
	return cp;
}
";}i:2;i:3;i:3;s:10702:" c++;>
#include "StdAfx.h"
#include "ImMouse.h"

#include "DefLibGR.h"
#include "DefLibRGB.h"
#include "Alg.h"
#include "Converter.h"
#include "Filter.h"
#include "Geometry.h"

void DefLibHistogram(DefLibGR& dib, float histo[256]){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	BYTE** ptr = dib.GetPtr();

	int temp[256];
	memset(temp, 0, sizeof(int)*256);
	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++) temp[ptr[j][i]]++;

	float area = (float)w*h;
	for(register int i = 0; i < 256; i++) histo[i] = temp[i] / area;
}
//
void DefLibHistEqual(DefLibGR& dib){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	float hist[256];
	DefLibHistogram(dib, hist);

	double cdf[256] = {0.0,};
	cdf[0] = hist[0];
	for(register int i = 1; i < 256; i++) cdf[i] = cdf[i-1] + hist[i];

	BYTE** ptr = dib.GetPtr();

	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++)	ptr[j][i] = (BYTE)limit(cdf[ptr[j][i]]*255);
}

void DefLibColorHistEqual(DefLibGR& dib){
	DefLibGR dibY, dibU, dibV;
	DefLibFilterColorSplitYUV(dib, dibY, dibU, dibV);

	DefLibHistEqual(dibY);

	DefLibFilterColorCombineYUV(dibY, dibU, dibV, dib);
	dibY.Destroy();
	dibU.Destroy();
	dibV.Destroy();
}

void DrawTraceLine(DefLibGR& dib, ContourPoints cp){
	DefLibRGB** ptr = dib.GetRGBPtr();
	
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.

	if(cp.num > 0){
		
		for(register int i=0; i<cp.num; i++){
			ptr[cp.y[i]][cp.x[i]].r = 0;
			ptr[cp.y[i]][cp.x[i]].g = 0;
			ptr[cp.y[i]][cp.x[i]].b = 0;
		}
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].r = 0;
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].g = 0;
		ptr[cp.miny + (cp.maxy-cp.miny)/2][cp.minx + (cp.maxx-cp.minx)/2].b = 0;
		for(register int j=0; j<8; j++)
			if((cp.miny + (cp.maxy-cp.miny)/2 + dy[j] >= 0 && cp.miny + (cp.maxy-cp.miny)/2 + dy[j] < h)
				&& (cp.minx + (cp.maxx-cp.minx)/2 + dx[j] >= 0 && cp.minx + (cp.maxx-cp.minx)/2 + dx[j] < w)){
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].r = 0;
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].g = 0;
					ptr[cp.miny + (cp.maxy-cp.miny)/2+dy[j]][cp.minx + (cp.maxx-cp.minx)/2+dx[j]].b = 0;
			}
	}
}

void DefLibGoTracePoint(DefLibGR& dib, GoingTrace& gt, int x, int y){
	DefLibRGB** ptr = dib.GetRGBPtr();

	int w = dib.GetWidth();
	int h = dib.GetHeight();

	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.
	
	if(gt.cnt==0){
		gt.minx = INFIN;
		gt.miny = INFIN;
		gt.maxx = 0;
		gt.maxy = 0;
	}
	
	gt.x[gt.cnt] = x;
	gt.y[gt.cnt++] = y;

	if(gt.minx > x) gt.minx = x;
	if(gt.miny > y) gt.miny = y;
	if(gt.maxx < x) gt.maxx = x;
	if(gt.maxy < y) gt.maxy = y;

	// 추적선을 바탕으로 경계선까지 함께 화면에 그려준다.
	for(register int i=0; i<gt.cnt; i++){
		ptr[gt.y[i]][gt.x[i]].r = 0;
		ptr[gt.y[i]][gt.x[i]].g = 0;
		ptr[gt.y[i]][gt.x[i]].b = 0;
		// 자취선은 조금더 굵은선..
		for(register int j=0; j<8; j++)
			if((gt.y[i] + dy[j] >= 0 && gt.y[i] + dy[j] < h)
				&& (gt.x[i] + dx[j] >= 0 && gt.x[i] + dx[j] < w)){
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].r = 0;
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].g = 0;
					ptr[gt.y[i]+dy[j]][gt.x[i]+dx[j]].b = 0;
			}
	}
	

	for(register int i=gt.minx; i<gt.maxx; i++){
		ptr[gt.miny][i].r = 0;
		ptr[gt.miny][i].g = 0;
		ptr[gt.miny][i].b = 0;

		ptr[gt.maxy][i].r = 0;
		ptr[gt.maxy][i].g = 0;
		ptr[gt.maxy][i].b = 0;
	}

	for(register int i=gt.miny; i<gt.maxy; i++){
		ptr[i][gt.minx].r = 0;
		ptr[i][gt.minx].g = 0;
		ptr[i][gt.minx].b = 0;

		ptr[i][gt.maxx].r = 0;
		ptr[i][gt.maxx].g = 0;
		ptr[i][gt.maxx].b = 0;
	}
}

void DefLibGoTraceMatchingAlphabet(GoingTrace& gt){
	int dx[8] = {0,1,1,1,0,-1-1-1}, dy[8] = {-1,-1,0,1,1,1,0,-1}; // 방향은 시계 방향임.
	gt.matchpoints = 32767;
	int w = gt.maxx-gt.minx+1;
	int h = gt.maxy-gt.miny+1;
	int kw = gt.maxx-gt.minx+1;
	int kh = gt.maxy-gt.miny+1;
	DefLibGR dib;
	dib.CreateRGBImage(w,h);
	DefLibRGB** ptr = dib.GetRGBPtr();
	// 여기가 좀 오래 걸릴것 같다..

	// 총 8방향에 대고 그린다 이유는 간단하다, 축소의 경우를 놓고 보면,
	// 축소할때 단면적이 작기 때문에 선이 모조리 사라지는 수가 생긴다. 그러므로 크게 점을 찍어주고
	// 후에 가우시안 필터 처리해준다.
	for(register int i=0; i<gt.cnt; i++){
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].r = 0;
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].g = 0;
		ptr[gt.y[i]-gt.miny][gt.x[i]-gt.minx].b = 0;
		// 절대 외곽선이 넘어가게 칠해지면 안되므로 다음과 같은 조치를 취한다.
		for(register int j=0; j<8; j++)
			if(((gt.y[i]-gt.miny) + dy[j] >= 0 && (gt.y[i]-gt.miny) + dy[j] < h)
				&& ((gt.x[i]-gt.minx) + dx[j] >= 0 && (gt.x[i]-gt.minx) + dx[j] < w)){
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].r = 0;
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].g = 0;
				ptr[(gt.y[i]-gt.miny)+dy[j]][(gt.x[i]-gt.minx)+dx[j]].b = 0;
			}
	}

	int isBlankLineX[SCR_WIDTH] = {0,};
	int isBlankLineY[SCR_HEIGHT] = {0,};
	int BLcntX=0;
	int BLcntY=0;
	
	// 여기서부터 공백을 없에주기위한 함수. 프레임이 끊겨서 생기는 현상 방지.
	// 그렇게 오래 처리 되지 않음.
	for(register int j=0; j<h; j++)
		for(register int i=0; i<w; i++)
			if(ptr[j][i].r == 0 && ptr[j][i].g == 0 && ptr[j][i].b == 0){
				isBlankLineY[j] = 1;
				break;
			}

	for(register int i=0; i<w; i++)
		for(register int j=0; j<h; j++)
			if(ptr[j][i].r == 0 && ptr[j][i].g == 0 && ptr[j][i].b == 0){
				isBlankLineX[i] = 1;
				break;
			}

	for(register int i=0; i<h; i++)
		if(isBlankLineY[i] == 0){
			for(register int j=i; j<h-1; j++)
				for(register int k=0; k<w; k++){
					ptr[j][k].r = ptr[j+1][k].r;
					ptr[j][k].g = ptr[j+1][k].g;
					ptr[j][k].b = ptr[j+1][k].b;
				}
			kh--;
		}

	for(register int i=0; i<w; i++)
		if(isBlankLineX[i] == 0){
			for(register int j=i; j<w-1; j++)
				for(register int k=0; k<h; k++){
					ptr[k][j].r = ptr[k][j+1].r;
					ptr[k][j].g = ptr[k][j+1].g;
					ptr[k][j].b = ptr[k][j+1].b;
				}
			kw--;
		}

	DefLibGR bak;

	bak.CreateRGBImage(kw,kh);

	DefLibRGB** bptr = bak.GetRGBPtr();

	for(register int j=0; j<kh; j++)
		for(register int i=0; i<kw; i++){
			bptr[j][i].r = ptr[j][i].r;
			bptr[j][i].g = ptr[j][i].g;
			bptr[j][i].b = ptr[j][i].b;
		}

	// 또한 없어지는것을 방지하기 위해 계속 노력해준다.. ㅡㅡ;;
		for(register int j=0; j<kh; j++)
			for(register int i=0; i<kw; i++){
				if(ptr[j][i].r==0){
					for(register int k=0; k<8; k++){
						if((j + dy[k] >= 0 && j + dy[k] < kh) && (i + dx[k] >= 0 && i + dx[k] < kw)){
							bptr[j+dy[k]][i+dx[k]].r = 0;
							bptr[j+dy[k]][i+dx[k]].g = 0;
							bptr[j+dy[k]][i+dx[k]].b = 0;
						}
					}
				}
			}

	// 여기까지가 공백 없에기..

	// 조합 : 3차 회선 보간 + 가우시안.

	// 가장 효율적인 조합으로 나타났다.

	// 이제 선이 조금은 굵어 졌으므로 가우시안 필터를 적용해보자.
	// 그런데 가우시안 그렇게 효율적이지는 못한듯.. 대략 가우시안 2.2정도에
	// 640 * 480 기준에 그려진 3줄이 지워지지 않는 최적의 수.

	// 여기서부터는 그림 축소.. 혹은 작으면 확대..

	// 640 * 480은.. 일단.
	// 640 * 480 이미지 -> 가우시안 -> 160 * 120 -> 가우시안 -> 17 * 17 이런 순서임.
	// 320 * 240도 마찬가지.. ㅎㅎ
	// 320 * 240 이미지 -> 가우시안 -> 160 * 120 -> 가우시안 -> 17 * 17 이런 순서임.

	if(kh<61 && kw<61){
		//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
		DefLibResizeCubic(bak,17,17);
	}
	else{
		if(kh>=240 && kw >=320){
			//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
			DefLibResizeCubic(bak,160,120);
		}
		//DefLibFilterGaussian(bak,2.2); // 일단 가우시안.
		DefLibResizeCubic(bak,17,17);
	}

	DefLibRGB** cptr = bak.GetRGBPtr();

	// 여기 까지 해주면 남는것은 흰색과, 오로지 다른색 뿐이다.

	// 이제 포인트 매치만 남음.
	char programpath[_MAX_PATH];
	GetCurrentDirectory( _MAX_PATH, programpath);

	for(register int i=0; i<26; i++){
		CString cs;
		cs.Format("%s\\Alpha\\%d.bmp",programpath,i+1);

		int scnt = 0;
		int pcnt = 0;
		DefLibGR Alphabet;
		Alphabet.Load((LPCTSTR)cs);

		DefLibRGB** Aptr = Alphabet.GetRGBPtr();

		for(register int j=0; j<17; j++)
			for(register int k=0; k<17; k++){
				if(Aptr[j][k].r == 255) pcnt++;
				if(Aptr[j][k].r != 255 && cptr[j][k].r != 255) scnt++;
			}

		int MatchtoX = 17*17-pcnt;
		int makeY = MatchtoX-scnt;
		if(makeY<gt.matchpoints){
			gt.matchpoints = makeY;
			gt.AlphabetNum = i;
		}
		/*
		if(scnt>gt.matchpoints){
			gt.matchpoints = scnt;
			gt.AlphabetNum = i;
		}*/
		Alphabet.Destroy();
	}

	// 7514번 루프 돔. 이게 훨씬 빠름.
	dib.Destroy();
	bak.Destroy();
}

// 이 알고리즘 책 참고. 대체 뭔지 기억이 안남.(10/05/27)
ContourPoints DefLibCTracing(DefLibGR& dib){
	int w = dib.GetWidth();
	int h = dib.GetHeight();

	// RGB영상의 binary가 들어오므로 RGB에서 보여주기 위하여 RGB좌표 처리.
	// 모든 값이 같으므로 r에대해서만 처리한다.

	DefLibRGB** ptr = dib.GetRGBPtr();

	int x, y, nx, ny;
	int dold, d, cnt;
	int dir[8][2] = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};

	ContourPoints cp;
	cp.num = 0;

	cp.minx = INFIN;
	cp.miny = INFIN;
	cp.maxx = 0;
	cp.maxy = 0;

	for(register int j = 0; j < h; j++)
		for(register int i = 0; i < w; i++){
			if(ptr[j][i].r == 0 || ptr[j][i].g == 0 || ptr[j][i].b == 0){
				x = i; y = j;
				dold = d = cnt = 0;

				while(1){
					nx = x + dir[d][0];
					ny = y + dir[d][1];
					
					if(nx < 0 || nx >= w || ny < 0 || ny >= h || 
						(ptr[ny][nx].r != 0 && ptr[ny][nx].g != 0 && ptr[ny][nx].b != 0)){
						if(++d > 7) d = 0;
						cnt++;

						if( cnt >= 8 ){
							cp.x[cp.num] = x;
							cp.y[cp.num] = y;
							if(cp.minx > x) cp.minx = x;
							if(cp.miny > y) cp.miny = y;
							if(cp.maxx < x) cp.maxx = x;
							if(cp.maxy < y) cp.maxy = y;
							cp.num++;
							break;
						}
					}
					else{
						cp.x[cp.num] = x;
						cp.y[cp.num] = y;
						cp.num++;

						if(cp.minx > x) cp.minx = x;
						if(cp.miny > y) cp.miny = y;
						if(cp.maxx < x) cp.maxx = x;
						if(cp.maxy < y) cp.maxy = y;

						if(cp.num >= MAX_CONTOUR) break;

						x = nx;	y = ny;
						cnt = 0; dold = d;
						d = ( dold + 6 ) % 8;
					}
				

					if( x == i && y == j && d == 0 ) break;
				}
				i = w; j = h;
			}
		}
	return cp;
}
";}i:2;i:5;}i:3;a:3:{i:0;s:5:"cdata";i:1;a:1:{i:0;s:0:"";}i:2;i:10713;}i:4;a:3:{i:0;s:7:"p_close";i:1;a:0:{}i:2;i:10713;}i:5;a:3:{i:0;s:12:"document_end";i:1;a:0:{}i:2;i:10713;}}