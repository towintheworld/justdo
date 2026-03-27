import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '我的',
          style: TextStyle(
            color: CupertinoColors.label,
            decoration: TextDecoration.none,
          ),
        ),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 用户信息头部
            _buildUserHeader(context),
            const SizedBox(height: 20),

            // 学习统计
            _buildSection(
              context,
              title: '学习统计',
              children: [
                _buildStatItem(
                  icon: CupertinoIcons.book_fill,
                  iconColor: CupertinoColors.systemBlue,
                  title: '已完成课程',
                  value: '12',
                ),
                _buildStatItem(
                  icon: CupertinoIcons.checkmark_circle_fill,
                  iconColor: CupertinoColors.systemGreen,
                  title: '已完成待办',
                  value: '58',
                ),
                _buildStatItem(
                  icon: CupertinoIcons.time_solid,
                  iconColor: CupertinoColors.systemOrange,
                  title: '专注时长',
                  value: '24小时',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 功能设置
            _buildSection(
              context,
              title: '功能',
              children: [
                _buildMenuItem(
                  icon: CupertinoIcons.bell_fill,
                  iconColor: CupertinoColors.systemRed,
                  title: '通知提醒',
                  onTap: () => _showComingSoon(context, '通知提醒'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.paintbrush_fill,
                  iconColor: CupertinoColors.systemPurple,
                  title: '外观设置',
                  onTap: () => _showComingSoon(context, '外观设置'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.cloud_fill,
                  iconColor: CupertinoColors.systemBlue,
                  title: 'iCloud同步',
                  onTap: () => _showComingSoon(context, 'iCloud同步'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.lock_fill,
                  iconColor: CupertinoColors.systemGrey,
                  title: '隐私设置',
                  onTap: () => _showComingSoon(context, '隐私设置'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 关于
            _buildSection(
              context,
              title: '关于',
              children: [
                _buildMenuItem(
                  icon: CupertinoIcons.info_circle_fill,
                  iconColor: CupertinoColors.systemBlue,
                  title: '关于应用',
                  showBadge: false,
                  onTap: () => _showAboutDialog(context),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.question_circle_fill,
                  iconColor: CupertinoColors.systemGreen,
                  title: '帮助中心',
                  onTap: () => _showComingSoon(context, '帮助中心'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.star_fill,
                  iconColor: CupertinoColors.systemYellow,
                  title: '给我们评分',
                  onTap: () => _showComingSoon(context, '评分'),
                ),
                _buildMenuItem(
                  icon: CupertinoIcons.share_solid,
                  iconColor: CupertinoColors.systemBlue,
                  title: '分享给好友',
                  onTap: () => _showComingSoon(context, '分享'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 退出登录
            _buildLogoutButton(context),
            const SizedBox(height: 16),

            // 版本信息
            Center(
              child: Text(
                '大学生助手 v1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 用户信息头部
  Widget _buildUserHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemBlue.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 36,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 16),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '大学生用户',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击编辑个人资料',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          // 箭头
          Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey3.resolveFrom(context),
            size: 20,
          ),
        ],
      ),
    );
  }

  // 分组列表
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey.resolveFrom(context),
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: _buildListItems(children)),
        ),
      ],
    );
  }

  // 构建列表项（带分隔线）
  List<Widget> _buildListItems(List<Widget> items) {
    final List<Widget> result = [];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Padding(
            padding: EdgeInsets.only(left: 54),
            child: Divider(height: 1, thickness: 0.5),
          ),
        );
      }
    }
    return result;
  }

  // 统计项
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  // 菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (showBadge)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemRed,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // 退出登录按钮
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        onPressed: () => _showLogoutDialog(context),
        child: const Text(
          '退出登录',
          style: TextStyle(
            color: CupertinoColors.systemRed,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  // 退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('退出'),
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, '退出登录');
            },
          ),
        ],
      ),
    );
  }

  // 关于应用对话框
  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('关于应用'),
        content: const Column(
          children: [
            SizedBox(height: 8),
            Icon(
              CupertinoIcons.book_fill,
              size: 48,
              color: CupertinoColors.systemBlue,
            ),
            SizedBox(height: 12),
            Text(
              '大学生助手',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '版本 1.0.0',
              style: TextStyle(
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '一个帮助大学生管理课程、待办事项和学习计划的效率工具。',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // 功能开发中提示
  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(feature),
        content: const Text('该功能正在开发中，敬请期待！'),
        actions: [
          CupertinoDialogAction(
            child: const Text('好的'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
