class_name DataContainer

var static_config: StaticConfig = StaticConfig.new()
var runtime_data: RuntimeData = RuntimeData.new()

# ===== 运行时数据访问 =====

func get_blogger() -> BloggerData:
    return runtime_data.blogger

func get_time() -> TimeData:
    return runtime_data.time

func get_bank() -> BankData:
    return runtime_data.bank

func get_ad() -> AdData:
    return runtime_data.ad

func get_statistics() -> StatisticsData:
    return runtime_data.statistics

func get_task() -> TaskData:
    return runtime_data.task

func get_league() -> LeagueData:
    return runtime_data.league

func get_friend_link() -> FriendLinkData:
    return runtime_data.friend_link

func get_comment() -> CommentData:
    return runtime_data.comment

func get_story_progress() -> StoryProgress:
    return runtime_data.story_progress

func get_yearly_summary() -> YearlySummaryData:
    if not runtime_data.yearly_summary:
        runtime_data.yearly_summary = YearlySummaryData.new()
    return runtime_data.yearly_summary

# ===== 静态配置访问 =====

func get_static_config() -> StaticConfig:
    return static_config

# ===== 数据重置 =====

func reset_runtime_data():
    runtime_data.reset()

func reset_all_data():
    runtime_data.reset()
    static_config = StaticConfig.new()