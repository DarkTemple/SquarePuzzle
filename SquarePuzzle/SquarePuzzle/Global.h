//
// Prefix header for all source files of the 'AppDefaultTemplate' target in the 'AppDefaultTemplate' project
//

#ifdef __OBJC__

static const CGFloat kLineWidth = 1.f;


#define FIND_ALL_SOLUTIONS

// 放置之后DFS检查最小连通空间
#define OPTIMIZE_ARRANGE_CONNECTED_DFS
// block变形去重
#define OPTIMIZE_BLOCK_TRANSFORM_DUP
// self.width, self.height 变量存储
#define OPTIMIZE_WIDTH_HEIGHT_GETTER
// 矩阵旋转的原地算法优化
#define OPTIMIZE_SQUARE_ROTATE
// objc call 优化为 纯C call
#define OPTIMIZE_MSGSEND
// remove block 搜索空间优化
#define OPTIMIZE_BLOCK_REMOVE
// arrange起始点优化（结束点）
#define OPTIMIZE_ARRANGE_SEARCH_RANGE
// DFS搜索空间的优化（只搜索block周围及内部空白点）
#define OPTIMIZE_DFS_SEARCH_POINT
// 遍历数组时候的ARC优化
#define OPTIMEZE_ENUMETATE_ARC

#endif
