// lib/core/widgets/tabela_classificacao.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';

class TabelaClassificacao extends StatelessWidget {
  final String title;
  final List<Atletica> data;

  const TabelaClassificacao({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classificação Geral',
                  style: const TextStyle(
                    fontFamily: 'Host Grotesk',
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 20,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Host Grotesk',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          Card(
            margin: EdgeInsets.zero,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              textDirection: TextDirection.ltr,
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: const TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.inputBorder,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                verticalInside: BorderSide.none,
                top: BorderSide.none,
                bottom: BorderSide.none,
                left: BorderSide.none,
                right: BorderSide.none,
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(2),
              },

              children: [
                // Cabeçalho da tabela
                TableRow(
                  children: [
                    _CenteredCell(
                      Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _CenteredCell(
                      Text(
                        'Atlética',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      isCenter: false,
                    ),
                    _CenteredCell(
                      SvgPicture.asset(AppIcons.icMedal, height: 17, width: 17),
                    ),
                    _CenteredCell(
                      SvgPicture.asset(
                        AppIcons.icMedal,
                        height: 17,
                        width: 17,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF848484),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    _CenteredCell(
                      SvgPicture.asset(
                        AppIcons.icMedal,
                        height: 17,
                        width: 17,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9A7147),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    _CenteredCell(
                      Text(
                        'Pontos',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Linhas da tabela (dados das atléticas)
                ...data.map((atletica) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: data.indexOf(atletica) % 2 == 0
                          ? AppColors.cardBackground
                          : Colors.white,
                    ),
                    children: [
                      _CenteredCell(Text(atletica.posicao.toString())),

                      _CenteredCell(Text(atletica.nome), isCenter: false),

                      _CenteredCell(Text(atletica.ouro.toString())),
                      _CenteredCell(Text(atletica.prata.toString())),

                      _CenteredCell(Text(atletica.bronze.toString())),
                      _CenteredCell(Text(atletica.pontos.toString())),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredCell extends StatelessWidget {
  final Widget child;
  final bool isCenter;
  const _CenteredCell(this.child, {this.isCenter = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: isCenter
          ? Center(child: child)
          : Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}
