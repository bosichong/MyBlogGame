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

# ===== 静态配置访问 =====

func get_static_config() -> StaticConfig:
    return static_config

# ===== 数据重置 =====

func reset_runtime_data():
    runtime_data.reset()

func reset_all_data():
    runtime_data.reset()
    static_config = StaticConfig.new()