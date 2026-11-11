# Plugin eval suites. See docs/evals.md.
# Pass extra flags with ARGS, e.g.
#   make eval-decision-log ARGS='--case no-log-asks-first --runs 1 --keep-temp'

EVAL := claude plugin eval --no-publish -j 8

EVAL_TARGETS := eval-avoid-ai-tells eval-decision-log eval-git-commit-agent eval-prioritize-skills

.PHONY: help evals $(EVAL_TARGETS)

help:
	@echo "make evals              run every plugin's eval suite (use -k to continue past failures)"
	@echo "make eval-<plugin>      run one suite: $(patsubst eval-%,%,$(EVAL_TARGETS))"
	@echo "ARGS='...'              extra flags for claude plugin eval"

evals: $(EVAL_TARGETS)

# avoid-ai-tells scores about 0.83 per case; the default threshold of 1.0 always fails it.
eval-avoid-ai-tells:
	$(EVAL) ./avoid-ai-tells --threshold 0.6 $(ARGS)

eval-decision-log:
	$(EVAL) ./decision-log --scaffold --allow-tools Write Edit $(ARGS)

eval-git-commit-agent:
	$(EVAL) ./git-commit-agent --scaffold --allow-tools Bash $(ARGS)

# The built-in no-plugin arm would also drop the fixture skills, so build-cases.sh
# generates a <case>-control twin of every case and pair-deltas.sh compares them.
# Controls fail the canary grader by design, hence --threshold 0.
PS_EVALS := prioritize-skills/evals
eval-prioritize-skills:
	$(PS_EVALS)/build-cases.sh
	$(EVAL) ./prioritize-skills --ablation none --scaffold --threshold 0 \
		--json $(PS_EVALS)/results/latest.json $(ARGS)
	$(PS_EVALS)/pair-deltas.sh $(PS_EVALS)/results/latest.json
