class_name RuntimeData

var blogger: BloggerData = BloggerData.new()
var time: TimeData = TimeData.new()
var bank: BankData = BankData.new()
var ad: AdData = AdData.new()
var statistics: StatisticsData = StatisticsData.new()
var task: TaskData = TaskData.new()
var league: LeagueData = LeagueData.new()

# 初始化所有数据
func reset():
	blogger = BloggerData.new()
	time = TimeData.new()
	bank = BankData.new()
	ad = AdData.new()
	statistics = StatisticsData.new()
	task = TaskData.new()
	league = LeagueData.new()
