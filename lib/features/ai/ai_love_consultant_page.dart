import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'ai_love_consultant_service.dart';

class AILoveConsultantPage extends ConsumerStatefulWidget {
  final String? partnerId;
  final String? partnerName;

  const AILoveConsultantPage({
    super.key,
    this.partnerId,
    this.partnerName,
  });

  @override
  ConsumerState<AILoveConsultantPage> createState() => _AILoveConsultantPageState();
}

class _AILoveConsultantPageState extends ConsumerState<AILoveConsultantPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBudget = 500;
  DateSuggestionType _selectedDateType = DateSuggestionType.firstDate;
  String _communicationScenario = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 標籤欄
          _buildTabBar(),
          
          // 內容區域
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDateSuggestionsTab(),
                _buildRelationshipAnalysisTab(),
                _buildCommunicationAdviceTab(),
                _buildMilestonesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI 愛情顧問',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.partnerName != null)
            Text(
              '與 ${widget.partnerName} 的關係',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.psychology),
          onPressed: () {
            _showAITips();
          },
          tooltip: 'AI 小貼士',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.pink,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.pink,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.favorite, size: 20),
            text: '約會建議',
          ),
          Tab(
            icon: Icon(Icons.analytics, size: 20),
            text: '關係分析',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble, size: 20),
            text: '溝通策略',
          ),
          Tab(
            icon: Icon(Icons.timeline, size: 20),
            text: '關係里程碑',
          ),
        ],
      ),
    );
  }

  Widget _buildDateSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 約會類型選擇
          _buildDateTypeSelector(),
          const SizedBox(height: 20),
          
          // 預算選擇
          _buildBudgetSelector(),
          const SizedBox(height: 20),
          
          // 生成建議按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.partnerId != null && !_isLoading
                  ? _generateDateSuggestions
                  : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? '生成中...' : '生成約會建議'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          if (widget.partnerId == null) ...[
            const SizedBox(height: 20),
            _buildNoPartnerMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '約會類型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DateSuggestionType.values.map((type) {
                final isSelected = _selectedDateType == type;
                return FilterChip(
                  label: Text(_getDateTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDateType = type;
                    });
                  },
                  selectedColor: Colors.pink[100],
                  checkmarkColor: Colors.pink,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '預算範圍: HK\$${_selectedBudget.toString()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _selectedBudget.toDouble(),
              min: 0,
              max: 3000,
              divisions: 30,
              activeColor: Colors.pink,
              onChanged: (value) {
                setState(() {
                  _selectedBudget = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '免費',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'HK\$3000+',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipAnalysisTab() {
    if (widget.partnerId == null) {
      return _buildNoPartnerMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 分析按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: !_isLoading ? _analyzeRelationship : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.analytics),
              label: Text(_isLoading ? '分析中...' : '分析關係狀態'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 分析說明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        '關係分析包含',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAnalysisFeature('兼容性評分', '基於 MBTI、興趣、價值觀的綜合分析'),
                  _buildAnalysisFeature('關係階段', '評估當前關係發展階段'),
                  _buildAnalysisFeature('優勢識別', '發現關係中的積極因素'),
                  _buildAnalysisFeature('挑戰分析', '識別需要關注的問題'),
                  _buildAnalysisFeature('發展建議', '個性化的關係發展建議'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationAdviceTab() {
    if (widget.partnerId == null) {
      return _buildNoPartnerMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 場景輸入
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '溝通場景',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '例如：表達不滿、討論未來、道歉等...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _communicationScenario = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 常見場景快捷選擇
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '常見場景',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '表達不滿',
                      '討論未來',
                      '道歉',
                      '表達愛意',
                      '解決衝突',
                      '分享感受',
                    ].map((scenario) {
                      return ActionChip(
                        label: Text(scenario),
                        onPressed: () {
                          setState(() {
                            _communicationScenario = scenario;
                          });
                        },
                        backgroundColor: Colors.pink[50],
                        labelStyle: TextStyle(color: Colors.pink[700]),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 生成建議按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _communicationScenario.isNotEmpty && !_isLoading
                  ? _generateCommunicationAdvice
                  : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.psychology),
              label: Text(_isLoading ? '生成中...' : '獲取溝通建議'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab() {
    if (widget.partnerId == null) {
      return _buildNoPartnerMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 生成里程碑按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: !_isLoading ? _generateMilestones : null,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.timeline),
              label: Text(_isLoading ? '生成中...' : '生成關係里程碑'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 里程碑說明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      const Text(
                        '關係里程碑',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '基於你們當前的關係階段，AI 會建議適合的關係發展里程碑，包括建議時機和準備事項。',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPartnerMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '需要選擇對象',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '請先選擇一個配對對象來獲取個性化的愛情建議',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('返回配對'),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateTypeLabel(DateSuggestionType type) {
    switch (type) {
      case DateSuggestionType.firstDate:
        return '首次約會';
      case DateSuggestionType.secondDate:
        return '第二次約會';
      case DateSuggestionType.romantic:
        return '浪漫約會';
      case DateSuggestionType.casual:
        return '輕鬆約會';
      case DateSuggestionType.activity:
        return '活動約會';
      case DateSuggestionType.indoor:
        return '室內約會';
      case DateSuggestionType.outdoor:
        return '戶外約會';
      case DateSuggestionType.budget:
        return '經濟約會';
      case DateSuggestionType.luxury:
        return '奢華約會';
    }
  }

  Future<void> _generateDateSuggestions() async {
    if (widget.partnerId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await ref
          .read(aiLoveConsultantServiceProvider)
          .generateDateSuggestions(
            partnerId: widget.partnerId!,
            type: _selectedDateType,
            budget: _selectedBudget,
          );

      if (mounted) {
        _showDateSuggestionsDialog(suggestions);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成約會建議失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _analyzeRelationship() async {
    if (widget.partnerId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final analysis = await ref
          .read(aiLoveConsultantServiceProvider)
          .analyzeRelationship(partnerId: widget.partnerId!);

      if (mounted) {
        _showRelationshipAnalysisDialog(analysis);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('關係分析失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateCommunicationAdvice() async {
    if (widget.partnerId == null || _communicationScenario.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final advice = await ref
          .read(aiLoveConsultantServiceProvider)
          .generateCommunicationAdvice(
            partnerId: widget.partnerId!,
            scenario: _communicationScenario,
          );

      if (mounted) {
        _showCommunicationAdviceDialog(advice);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成溝通建議失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateMilestones() async {
    if (widget.partnerId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final milestones = await ref
          .read(aiLoveConsultantServiceProvider)
          .generateRelationshipMilestones(partnerId: widget.partnerId!);

      if (mounted) {
        _showMilestonesDialog(milestones);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成里程碑失敗: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDateSuggestionsDialog(List<DateSuggestion> suggestions) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.pink[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '約會建議',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 建議列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return _buildDateSuggestionCard(suggestion);
                  },
                ),
              ),
              
              // 關閉按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSuggestionCard(DateSuggestion suggestion) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(suggestion.compatibilityScore * 100).round()}% 匹配',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.pink[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    suggestion.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'HK\$${suggestion.estimatedCost}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${suggestion.estimatedDuration.inHours}小時',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (suggestion.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: suggestion.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: const TextStyle(fontSize: 10),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              suggestion.reasoning,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelationshipAnalysisDialog(RelationshipAnalysis analysis) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '關係分析報告',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 分析內容
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 兼容性分數
                      _buildAnalysisSection(
                        '兼容性分數',
                        '${(analysis.compatibilityScore * 100).round()}%',
                        Colors.blue,
                      ),
                      
                      // 關係階段
                      _buildAnalysisSection(
                        '關係階段',
                        _getStageLabel(analysis.currentStage),
                        Colors.green,
                      ),
                      
                      // 優勢
                      if (analysis.strengths.isNotEmpty)
                        _buildAnalysisListSection(
                          '關係優勢',
                          analysis.strengths,
                          Colors.green,
                        ),
                      
                      // 挑戰
                      if (analysis.challenges.isNotEmpty)
                        _buildAnalysisListSection(
                          '需要關注',
                          analysis.challenges,
                          Colors.orange,
                        ),
                      
                      // 建議
                      if (analysis.recommendations.isNotEmpty)
                        _buildAnalysisListSection(
                          '發展建議',
                          analysis.recommendations,
                          Colors.purple,
                        ),
                    ],
                  ),
                ),
              ),
              
              // 關閉按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisListSection(String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showCommunicationAdviceDialog(CommunicationAdvice advice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '溝通建議',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 建議內容
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 場景
                      _buildAdviceSection('場景', advice.scenario, Colors.blue),
                      
                      // 建議
                      _buildAdviceSection('建議', advice.suggestion, Colors.green),
                      
                      // 應該做的
                      if (advice.dosList.isNotEmpty)
                        _buildAdviceListSection('應該做的', advice.dosList, Colors.green),
                      
                      // 不應該做的
                      if (advice.dontsList.isNotEmpty)
                        _buildAdviceListSection('避免做的', advice.dontsList, Colors.red),
                      
                      // 原因
                      _buildAdviceSection('原因', advice.reasoning, Colors.purple),
                    ],
                  ),
                ),
              ),
              
              // 關閉按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceSection(String title, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceListSection(String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showMilestonesDialog(List<RelationshipMilestone> milestones) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    const Text(
                      '關係里程碑',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 里程碑列表
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = milestones[index];
                    return _buildMilestoneCard(milestone);
                  },
                ),
              ),
              
              // 關閉按鈕
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(RelationshipMilestone milestone) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    milestone.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DateFormat('MM/dd').format(milestone.suggestedTiming),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              milestone.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            if (milestone.preparationTips.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '準備建議：',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...milestone.preparationTips.map((tip) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  String _getStageLabel(RelationshipStage stage) {
    switch (stage) {
      case RelationshipStage.initial:
        return '初期接觸';
      case RelationshipStage.getting_to_know:
        return '了解階段';
      case RelationshipStage.dating:
        return '約會階段';
      case RelationshipStage.exclusive:
        return '專一關係';
      case RelationshipStage.serious:
        return '認真關係';
      case RelationshipStage.committed:
        return '承諾關係';
    }
  }

  void _showAITips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.pink),
            SizedBox(width: 8),
            Text('AI 小貼士'),
          ],
        ),
        content: const Text(
          'AI 愛情顧問基於心理學研究和大數據分析，為您提供個性化的戀愛建議。'
          '建議僅供參考，真實的感情需要雙方的真誠溝通和理解。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }
} 