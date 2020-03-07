namespace :batch do
  desc "Cron Update Execute!"
  task execute_cron: :environment do
	CC = CronController.new()
	@Cron = Cron.all
	CC.UpdateSequence()
  end

end
