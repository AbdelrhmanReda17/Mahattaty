import 'package:flutter/material.dart';
import 'package:mahattaty/core/generic%20components/mahattaty_empty_data.dart';
import '../../../../core/utils/open_screens.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/train.dart';
import '../screens/ticket_details_screen.dart';
import 'cards/train_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserTicketsUpComing extends StatelessWidget {
  const UserTicketsUpComing({super.key, required this.tickets});

  final Map<Ticket, Train> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return MahattatyEmptyData(message: AppLocalizations.of(context)!.emptyUserTickets);
    }
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: TrainCard(
            train: tickets.values.elementAt(index),
            ticketType: tickets.keys.elementAt(index).type,
            seatType: tickets.keys.elementAt(index).seatType,
            departureStation:
                tickets.values.elementAt(index).trainDepartureStation,
            arrivalStation: tickets.values.elementAt(index).trainArrivalStation,
            displayTrainTicketCard: true,
            ticket: tickets.keys.elementAt(index),
            onTrainSelected: (ticket, train) {
              OpenScreen.openScreenWithSmoothAnimation(
                context,
                TicketDetailScreen(
                  ticket: ticket!,
                  train: train!,
                ),
                false,
              );
            },
          ),
        );
      },
    );
  }
}
